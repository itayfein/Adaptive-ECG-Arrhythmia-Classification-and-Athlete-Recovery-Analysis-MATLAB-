clear; clc; close all;

addpath('../src');
addpath('..');

cfg = config();

records = ["100","101","102","103","104","105","106","107","108","109", ...
           "111","112","113","114","115","116","117","118","119", ...
           "121","122","123","124", ...
           "200","201","202","203","205","207","208","209", ...
           "210","212","213","214","215","217","219","220", ...
           "221","222","223","228","230","231","232","233","234"];

all_features = table();

for r = 1:length(records)

    record_name = records(r);

    fprintf('\nProcessing record %s...\n', record_name);

    [ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record_direct(record_name);

    ecg_signal = ecg_signal - mean(ecg_signal);

    quality = signal_quality_assessment(ecg_signal, fs);

    [ecg_filtered, filter_info] = adaptive_filter_engine(ecg_signal, fs, quality, cfg);

    supported_labels = ["N", "A", "V", "F", "L", "R"];

    valid_idx = ismember(ann_symbols, supported_labels);

    r_locs = ann_samples(valid_idx);
    labels = ann_symbols(valid_idx);

    [beats, valid_r_locs, beat_time_axis] = segment_beats(ecg_filtered, r_locs, fs, cfg);

    [~, label_idx] = ismember(valid_r_locs, r_locs);
    valid_labels = labels(label_idx);

    features_table = extract_features(beats, valid_r_locs, fs);

    features_table.Label = categorical(valid_labels);
    features_table.Record = repmat(categorical(record_name), height(features_table), 1);

    features_table = rmmissing(features_table);

    all_features = [all_features; features_table];

end

disp("=== Final Label Distribution ===");
summary(all_features.Label)

output_dir = '../results/metrics';

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

output_file = fullfile(output_dir, 'features_mitbih_multi_record.csv');

writetable(all_features, output_file);

disp("Exported multi-record MIT-BIH dataset to:");
disp(output_file);

figure;
gscatter(all_features.peak_to_peak, all_features.beat_energy, all_features.Label);
grid on;
xlabel('Peak-to-Peak Amplitude');
ylabel('Beat Energy');
title('MIT-BIH Multi-Record Beat Features by Class');