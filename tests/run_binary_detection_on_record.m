clear; clc; close all;

addpath('../src');
addpath('src/classification');
addpath('../Classification Learner');
addpath('..');

cfg = config();

debug_mode = false;

%% Load MIT-BIH record

record_name = '101';

[ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record_direct(record_name);

ecg_signal = ecg_signal - mean(ecg_signal);

%% Signal quality assessment

quality = signal_quality_assessment(ecg_signal, fs);

disp("=== Signal Quality ===");
disp(quality);

%% Adaptive filtering

[ecg_filtered, filter_info] = adaptive_filter_engine(ecg_signal, fs, quality, cfg);

disp("=== Filter Decisions ===");
disp(filter_info);
filter_analysis = visualize_filter_design(fs, filter_info);

%% Use MIT-BIH annotations as beat locations

supported_labels = ["N", "A", "V", "F", "L", "R"];

valid_idx = ismember(ann_symbols, supported_labels);

r_locs = ann_samples(valid_idx);
true_labels = ann_symbols(valid_idx);

%% Segment beats

[beats, valid_r_locs, beat_time_axis] = segment_beats(ecg_filtered, r_locs, fs, cfg);

[~, label_idx] = ismember(valid_r_locs, r_locs);
true_labels = true_labels(label_idx);

%% Extract features

features_table = extract_features(beats, valid_r_locs, fs);

missing_rows = any(ismissing(features_table), 2);

features_table = features_table(~missing_rows, :);
valid_r_locs = valid_r_locs(~missing_rows);
true_labels = true_labels(~missing_rows);

%% Predict using exported Classification Learner function

model_file = '../src/classification/trainedModel_binary.mat';
load(model_file, 'trainedModel_binary');

[predicted_labels, scores] = trainedModel_binary.predictFcn(features_table);
%% Create true binary labels

true_labels = true_labels(~ismissing(features_table.heart_rate_bpm));

true_binary = strings(length(true_labels), 1);
true_binary(true_labels == "N") = "Normal";
true_binary(true_labels ~= "N") = "Abnormal";

true_binary = categorical(true_binary, ...
    ["Normal","Abnormal"]);

predicted_labels = categorical(predicted_labels, ...
    ["Normal","Abnormal"]);
%% Compare predictions with true labels

figure;
hold off;
confusionchart(true_binary, predicted_labels);
title('True vs Predicted Binary Arrhythmia Classification');

if debug_mode
    %% Debug: compare true abnormal locations vs predicted abnormal locations

    true_abnormal_idx = true_binary == "Abnormal";
    pred_abnormal_idx = predicted_labels == "Abnormal";

    disp("=== True abnormal labels in this record ===");
    summary(categorical(true_labels(true_abnormal_idx)))

    disp("Number of true abnormal beats:");
    disp(sum(true_abnormal_idx));

    disp("Number of predicted abnormal beats:");
    disp(sum(pred_abnormal_idx));

    disp("Correct abnormal detections:");
    disp(sum(true_abnormal_idx & pred_abnormal_idx));

    disp("False negatives:");
    disp(sum(true_abnormal_idx & ~pred_abnormal_idx));

    disp("False positives:");
    disp(sum(~true_abnormal_idx & pred_abnormal_idx));
end


%% Post-exercise athlete metrics

metrics = analyze_post_exercise_metrics(features_table, predicted_labels, fs);

disp("=== Athlete Post-Exercise Metrics ===");
disp(metrics);

report = generate_athlete_report(metrics);

for i = 1:length(report)
    disp(report(i));
end
%% Plot first 10 seconds with predictions

t = (0:length(ecg_filtered)-1) / fs;

segment_seconds = 10;
segment_samples = segment_seconds * fs;

figure;
plot(t(1:segment_samples), ecg_filtered(1:segment_samples));
hold on;
grid on;

xlabel('Time [s]');
ylabel('Amplitude');
title('Binary Arrhythmia Detection on MIT-BIH ECG');

segment_idx = valid_r_locs <= segment_samples;

segment_locs = valid_r_locs(segment_idx);
segment_preds = predicted_labels(segment_idx);

normal_idx = segment_preds == "Normal";
abnormal_idx = segment_preds == "Abnormal";

plot(t(segment_locs(normal_idx)), ...
     ecg_filtered(segment_locs(normal_idx)), ...
     'gv', ...
     'MarkerFaceColor', 'g');

plot(t(segment_locs(abnormal_idx)), ...
     ecg_filtered(segment_locs(abnormal_idx)), ...
     'rv', ...
     'MarkerFaceColor', 'r');

legend('Filtered ECG', 'Predicted Normal', 'Predicted Abnormal');


%% Plot heart-rate recovery trend

rr = features_table.rr_interval;
hr = features_table.heart_rate_bpm;

valid_idx = ~isnan(rr) & ~isnan(hr);

rr_valid = rr(valid_idx);
hr_valid = hr(valid_idx);

time_hr = cumsum(rr_valid) / 60; % time in minutes

figure;

plot(time_hr, hr_valid, 'LineWidth', 1.2);
grid on;

xlabel('Time [min]');
ylabel('Heart Rate [bpm]');
title('Heart Rate Recovery Trend');

hold on;

p = polyfit(time_hr, hr_valid, 1);
trend_line = polyval(p, time_hr);

plot(time_hr, trend_line, '--', 'LineWidth', 1.5);

legend('Instantaneous HR', 'Trend Line');

report_dir = '../results/reports';

if ~exist(report_dir, 'dir')
    mkdir(report_dir);
end

report_file = fullfile(report_dir, ['athlete_report_record_' record_name '.txt']);

fid = fopen(report_file, 'w');

for i = 1:length(report)
    fprintf(fid, '%s\n', report(i));
end

fclose(fid);

disp("Report saved to:");
disp(report_file);