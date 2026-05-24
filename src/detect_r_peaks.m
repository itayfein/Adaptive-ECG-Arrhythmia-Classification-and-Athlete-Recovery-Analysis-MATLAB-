function [r_peaks, r_locs] = detect_r_peaks(ecg_signal, fs, cfg)
%DETECT_R_PEAKS Detect R-peaks in filtered ECG signal
%
% Inputs:
%   ecg_signal - filtered ECG signal
%   fs         - sampling frequency [Hz]
%   cfg        - config struct
%
% Outputs:
%   r_peaks    - detected R-peak amplitudes
%   r_locs     - detected R-peak sample locations

    ecg_signal = ecg_signal(:);

    %% Adaptive threshold
    peak_threshold = cfg.peak_threshold_factor * max(ecg_signal);

    %% Minimum peak distance
    min_peak_distance = round(cfg.min_peak_distance_sec * fs);

    %% Peak detection
    [r_peaks, r_locs] = findpeaks( ...
        ecg_signal, ...
        'MinPeakHeight', peak_threshold, ...
        'MinPeakDistance', min_peak_distance);

end