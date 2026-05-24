clear; clc; close all;

addpath('../src');
addpath('..');

cfg = config();

%% Load real MIT-BIH record

record_name = '100';

[ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record_direct(record_name);

%% Remove DC offset

ecg_signal = ecg_signal - mean(ecg_signal);

%% Signal quality assessment

quality = signal_quality_assessment(ecg_signal, fs);

disp("=== Signal Quality Metrics ===");
disp(quality);

%% Adaptive filtering

[ecg_filtered, filter_info] = adaptive_filter_engine(ecg_signal, fs, quality, cfg);

disp("=== Adaptive Filter Decisions ===");
disp(filter_info);

%% Use MIT-BIH annotations as R-peak locations

r_locs = ann_samples;
labels = ann_symbols;

%% Keep only supported labels

supported_labels = ["N", "A", "V", "F", "L", "R"];

valid_idx = ismember(labels, supported_labels);

r_locs = r_locs(valid_idx);
labels = labels(valid_idx);

%% Beat segmentation

[beats, valid_r_locs, beat_time_axis] = segment_beats(ecg_filtered, r_locs, fs, cfg);

%% Match labels after removing invalid edge beats

[~, label_idx] = ismember(valid_r_locs, r_locs);
valid_labels = labels(label_idx);

%% Feature extraction

features_table = extract_features(beats, valid_r_locs, fs);

features_table.Label = categorical(valid_labels);

%% Remove rows with missing values

features_table = rmmissing(features_table);

%% Display label distribution

disp("=== Label Distribution ===");
summary(features_table.Label)

%% Export table

output_dir = '../results/metrics';

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

output_file = fullfile(output_dir, 'features_real_mitbih.csv');

writetable(features_table, output_file);

disp("Exported real MIT-BIH features to:");
disp(output_file);

%% Plot example beats by label

figure;
gscatter(features_table.peak_to_peak, ...
         features_table.beat_energy, ...
         features_table.Label);

grid on;
xlabel('Peak-to-Peak Amplitude');
ylabel('Beat Energy');
title('MIT-BIH Beat Features by Class');