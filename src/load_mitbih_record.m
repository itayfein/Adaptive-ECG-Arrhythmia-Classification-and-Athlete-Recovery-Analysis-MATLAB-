function [ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record(record_name)
%LOAD_MITBIH_RECORD Load ECG signal and annotations from MIT-BIH database
%
% Inputs:
%   record_name - string, e.g. '100'
%
% Outputs:
%   ecg_signal  - ECG signal vector
%   fs          - sampling frequency
%   ann_samples - annotation sample locations
%   ann_symbols - annotation labels

    database_path = '../data/mit-bih-arrhythmia-database-1.0.0/';

    record_path = fullfile(database_path, record_name);

    %% Load ECG signal
    [signal, fs, tm] = rdsamp(record_path);

    %% Use first ECG channel
    ecg_signal = signal(:,1);

    %% Load annotations
    [ann_samples, ann_symbols] = rdann(record_path, 'atr');

    fprintf('Loaded MIT-BIH record: %s\n', record_name);
    fprintf('Signal length: %d samples\n', length(ecg_signal));
    fprintf('Sampling frequency: %d Hz\n', fs);
    fprintf('Number of annotations: %d\n', length(ann_samples));

end