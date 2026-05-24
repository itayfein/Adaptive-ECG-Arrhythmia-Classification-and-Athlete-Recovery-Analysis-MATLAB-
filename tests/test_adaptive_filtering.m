%% test_adaptive_filtering.m
% Visual test for the adaptive ECG filtering module

clear; clc; close all;

%% Paths
addpath('../src');
addpath('..');

%% Load config
cfg = config();
fs = cfg.fs;

%% Create simulated noisy ECG-like signal
t = 0:1/fs:10;

ecg_clean = 1.2*sin(2*pi*1.2*t) ...
          + 0.25*sin(2*pi*2.4*t) ...
          + 0.1*sin(2*pi*3.6*t);

baseline_noise = 0.8*sin(2*pi*0.2*t);
high_freq_noise = 0.6*sin(2*pi*70*t);
powerline_noise = 0.5*sin(2*pi*50*t);
random_noise = 0.15*randn(size(t));

ecg_noisy = ecg_clean + baseline_noise + high_freq_noise + powerline_noise + random_noise;

%% Signal quality assessment
quality = signal_quality_assessment(ecg_noisy, fs);

%% Adaptive filtering
[ecg_filtered, filter_info] = adaptive_filter_engine(ecg_noisy, fs, quality, cfg);

%% Display filter decisions
disp("=== Signal Quality Metrics ===")
disp(quality)

disp("=== Adaptive Filter Decisions ===")
disp(filter_info)

%% Time-domain plot
figure;
plot(t, ecg_noisy);
hold on;
plot(t, ecg_filtered, 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Amplitude');
title('Adaptive ECG Filtering: Time Domain');
legend('Noisy ECG', 'Filtered ECG');

%% FFT comparison
N = length(ecg_noisy);
f = (0:N-1)*(fs/N);

fft_noisy = abs(fft(ecg_noisy));
fft_filtered = abs(fft(ecg_filtered));

half_range = 1:floor(N/2);

figure;
plot(f(half_range), fft_noisy(half_range));
hold on;
plot(f(half_range), fft_filtered(half_range), 'LineWidth', 1.2);
grid on;
xlabel('Frequency [Hz]');
ylabel('Magnitude');
title('Adaptive ECG Filtering: Frequency Domain');
legend('Noisy ECG', 'Filtered ECG');
xlim([0 100]);

%% Save figures
results_dir = '../results/figures';

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

saveas(1, fullfile(results_dir, 'adaptive_filtering_time_domain.png'));
saveas(2, fullfile(results_dir, 'adaptive_filtering_frequency_domain.png'));

disp("Figures saved to results/figures");

%% R-peak detection

[r_peaks, r_locs] = detect_r_peaks(ecg_filtered, fs, cfg);

%% Plot detected R-peaks

figure;

plot(t, ecg_filtered);
hold on;

plot(t(r_locs), r_peaks, 'rv', ...
    'MarkerFaceColor', 'r', ...
    'MarkerSize', 8);

grid on;

xlabel('Time [s]');
ylabel('Amplitude');

title('Detected R-Peaks');

legend('Filtered ECG', 'R-Peaks');

%% Beat segmentation

[beats, valid_r_locs, beat_time_axis] = segment_beats(ecg_filtered, r_locs, fs, cfg);

disp("Number of segmented beats:");
disp(size(beats, 1));

%% Plot segmented beats

figure;

plot(beat_time_axis, beats');
grid on;

xlabel('Time relative to R-peak [s]');
ylabel('Amplitude');

title('Segmented ECG Beats');

%% Feature extraction

features_table = extract_features(beats, valid_r_locs, fs);

disp("Extracted features:");
disp(features_table);

%% Add temporary labels for Classification Learner testing

num_beats = height(features_table);

labels = repmat("Normal", num_beats, 1);

% Temporary artificial labels only for testing Classification Learner
labels(features_table.heart_rate_bpm > 73) = "Abnormal";

features_table.Label = categorical(labels);

%% Remove rows with missing values

features_table = rmmissing(features_table);
%% Export features table

output_dir = '../results/metrics';

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

output_file = fullfile(output_dir, 'features_table.csv');

writetable(features_table, output_file);

disp("Features table exported to:");
disp(output_file);