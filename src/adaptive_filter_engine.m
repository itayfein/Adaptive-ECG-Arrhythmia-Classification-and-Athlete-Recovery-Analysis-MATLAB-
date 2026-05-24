function [ecg_filtered, filter_info] = adaptive_filter_engine(ecg_signal, fs, quality, cfg)
%ADAPTIVE_FILTER_ENGINE Adaptive ECG filtering based on signal quality.
%
% Inputs:
%   ecg_signal - raw ECG signal vector
%   fs         - sampling frequency [Hz]
%   quality    - struct from signal_quality_assessment
%   cfg        - configuration struct
%
% Outputs:
%   ecg_filtered - filtered ECG signal
%   filter_info  - struct describing selected filter parameters

    ecg_signal = ecg_signal(:);

    % Default filter parameters
    low_cutoff = cfg.default_low_cutoff;
    high_cutoff = cfg.default_high_cutoff;
    filter_order = cfg.filter_order;

    % Adaptive high-pass decision
    if quality.baseline_ratio > cfg.baseline_power_threshold
        low_cutoff = 1.0;
        filter_info.baseline_action = "Stronger high-pass filtering";
    else
        filter_info.baseline_action = "Default high-pass filtering";
    end

    % Adaptive low-pass decision
    if quality.high_freq_ratio > cfg.high_freq_power_threshold
        high_cutoff = 30;
        filter_info.high_freq_action = "Stronger low-pass filtering";
    else
        filter_info.high_freq_action = "Default low-pass filtering";
    end

    % Save selected parameters
    filter_info.low_cutoff = low_cutoff;
    filter_info.high_cutoff = high_cutoff;
    filter_info.filter_order = filter_order;

    % Design adaptive bandpass filter
    [b_band, a_band] = butter(filter_order, ...
        [low_cutoff high_cutoff] / (fs/2), ...
        'bandpass');

    % Apply zero-phase filtering
    ecg_bandpassed = filtfilt(b_band, a_band, ecg_signal);

    % Powerline notch filtering decision
    if quality.powerline_ratio > cfg.powerline_threshold
        notch_freq = cfg.notch_freq;
       % Manual notch filter design
        wo = 2*pi*notch_freq/fs;
        r = 0.98;
        b_notch = [1 -2*cos(wo) 1];
        a_notch = [1 -2*r*cos(wo) r^2];
        ecg_filtered = filtfilt(b_notch, a_notch, ecg_bandpassed);

        filter_info.notch_applied = true;
        filter_info.notch_action = "50 Hz notch filter applied";
    else
        ecg_filtered = ecg_bandpassed;

        filter_info.notch_applied = false;
        filter_info.notch_action = "No notch filter applied";
    end

end