clear; clc; close all;

addpath('../src');

[ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record_direct('100');

%% Plot short ECG segment

t = (0:length(ecg_signal)-1)/fs;

figure;

segment_seconds = 10;

segment_samples = segment_seconds * fs;

plot(t(1:segment_samples), ecg_signal(1:segment_samples));

grid on;

xlabel('Time [s]');
ylabel('Amplitude');

title('MIT-BIH ECG Record 100 (10-second segment)');

%% Display first annotations

disp("First 20 annotation samples:");
disp(ann_samples(1:min(20,end)));

disp("First 20 annotation symbols:");
disp(ann_symbols(1:min(20,end)));

%% Plot annotations on short segment

hold on;

segment_annotations = ann_samples(ann_samples <= segment_samples);

plot(t(segment_annotations), ...
     ecg_signal(segment_annotations), ...
     'rv', ...
     'MarkerFaceColor', 'r');

legend('ECG Signal', 'Annotations');