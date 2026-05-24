clear; clc; close all;

%% Load balanced multi-class dataset

input_file = '../results/metrics/features_mitbih_balanced.csv';

T = readtable(input_file);

T.Label = categorical(T.Label);

%% Create binary labels

binary_labels = strings(height(T), 1);

binary_labels(T.Label == "N") = "Normal";
binary_labels(T.Label ~= "N") = "Abnormal";

T.BinaryLabel = categorical(binary_labels);

%% Remove original multi-class label from predictors later manually
% In Classification Learner:
% Response = BinaryLabel
% Uncheck Label and Record from predictors

%% Display distribution

disp("=== Binary Label Distribution ===");
summary(T.BinaryLabel)

%% Export

output_file = '../results/metrics/features_mitbih_binary.csv';

writetable(T, output_file);

disp("Binary dataset exported to:");
disp(output_file);

%% Plot

figure;

gscatter(T.peak_to_peak, ...
         T.beat_energy, ...
         T.BinaryLabel);

grid on;
xlabel('Peak-to-Peak Amplitude');
ylabel('Beat Energy');
title('MIT-BIH Binary Classification: Normal vs Abnormal');