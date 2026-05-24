clear; clc; close all;

%% Load multi-record dataset

input_file = '../results/metrics/features_mitbih_multi_record.csv';

T = readtable(input_file);

T.Label = categorical(T.Label);

%% Display original distribution

disp("=== Original Label Distribution ===");
summary(T.Label)

%% Separate classes

T_N = T(T.Label == "N", :);
T_L = T(T.Label == "L", :);
T_R = T(T.Label == "R", :);
T_V = T(T.Label == "V", :);
T_A = T(T.Label == "A", :);
T_F = T(T.Label == "F", :);

%% Downsample majority classes

rng(42);

max_N = 20000;
max_L = 8000;
max_R = 8000;

T_N_bal = T_N(randperm(height(T_N), min(max_N, height(T_N))), :);
T_L_bal = T_L(randperm(height(T_L), min(max_L, height(T_L))), :);
T_R_bal = T_R(randperm(height(T_R), min(max_R, height(T_R))), :);
%% Keep all minority classes

T_balanced = [T_N_bal; T_L_bal; T_R_bal; T_V; T_A; T_F];

%% Shuffle rows

T_balanced = T_balanced(randperm(height(T_balanced)), :);

%% Display balanced distribution

disp("=== Balanced Label Distribution ===");
summary(T_balanced.Label)

%% Export balanced dataset

output_file = '../results/metrics/features_mitbih_balanced.csv';

writetable(T_balanced, output_file);

disp("Balanced dataset exported to:");
disp(output_file);

%% Plot balanced features

figure;

gscatter(T_balanced.peak_to_peak, ...
         T_balanced.beat_energy, ...
         T_balanced.Label);

grid on;
xlabel('Peak-to-Peak Amplitude');
ylabel('Beat Energy');
title('Balanced MIT-BIH Beat Features by Class');