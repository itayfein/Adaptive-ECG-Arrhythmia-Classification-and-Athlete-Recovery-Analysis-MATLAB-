clear; clc; close all;

addpath('../src');
addpath('../src/classification');
addpath('..');

cfg = config();

model_file = '../src/classification/trainedModel_binary.mat';
load(model_file, 'trainedModel_binary');

records = ["100","101","106","109","119","200","207","208","213","221","233"];

results = table();

for r = 1:length(records)

    record_name = records(r);

    fprintf('\nEvaluating record %s...\n', record_name);

    [ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record_direct(record_name);

    ecg_signal = ecg_signal - mean(ecg_signal);

    quality = signal_quality_assessment(ecg_signal, fs);
    [ecg_filtered, ~] = adaptive_filter_engine(ecg_signal, fs, quality, cfg);

    supported_labels = ["N", "A", "V", "F", "L", "R"];
    valid_idx = ismember(ann_symbols, supported_labels);

    r_locs = ann_samples(valid_idx);
    true_labels = ann_symbols(valid_idx);

    [beats, valid_r_locs, ~] = segment_beats(ecg_filtered, r_locs, fs, cfg);

    [~, label_idx] = ismember(valid_r_locs, r_locs);
    true_labels = true_labels(label_idx);

    features_table = extract_features(beats, valid_r_locs, fs);

    missing_rows = any(ismissing(features_table), 2);

    features_table = features_table(~missing_rows, :);
    true_labels = true_labels(~missing_rows);

    [predicted_labels, ~] = trainedModel_binary.predictFcn(features_table);

    true_binary = strings(length(true_labels), 1);
    true_binary(true_labels == "N") = "Normal";
    true_binary(true_labels ~= "N") = "Abnormal";

    true_binary = categorical(true_binary, ["Normal","Abnormal"]);
    predicted_labels = categorical(predicted_labels, ["Normal","Abnormal"]);

    TP = sum(true_binary == "Abnormal" & predicted_labels == "Abnormal");
    TN = sum(true_binary == "Normal" & predicted_labels == "Normal");
    FP = sum(true_binary == "Normal" & predicted_labels == "Abnormal");
    FN = sum(true_binary == "Abnormal" & predicted_labels == "Normal");

    accuracy = (TP + TN) / (TP + TN + FP + FN);
    abnormal_recall = TP / (TP + FN);
    specificity = TN / (TN + FP);

    new_row = table( ...
        string(record_name), ...
        TP, TN, FP, FN, ...
        accuracy, abnormal_recall, specificity, ...
        'VariableNames', {'Record','TP','TN','FP','FN','Accuracy','AbnormalRecall','Specificity'});

    results = [results; new_row];

end

disp("=== Evaluation Results ===");
disp(results);

output_file = '../results/metrics/evaluation_by_record.csv';
writetable(results, output_file);

disp("Saved evaluation results to:");
disp(output_file);