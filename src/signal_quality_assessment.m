function quality = signal_quality_assessment(ecg_signal, fs)
%SIGNAL_QUALITY_ASSESSMENT Estimate ECG signal quality metrics.
%
% Inputs:
%   ecg_signal - raw ECG signal vector
%   fs         - sampling frequency [Hz]
%
% Output:
%   quality    - struct containing signal quality metrics

    ecg_signal = ecg_signal(:);

    % Remove DC component
    ecg_centered = ecg_signal - mean(ecg_signal);

    % Frequency bands
    baseline_band = [0 0.5];
    ecg_band = [0.5 40];
    high_freq_band = [40 min(100, fs/2 - 1)];
    powerline_band = [49 51];

    % Power calculations
    total_power = bandpower(ecg_centered, fs, [0 fs/2 - 1]);

    baseline_power = bandpower(ecg_centered, fs, baseline_band);
    ecg_power = bandpower(ecg_centered, fs, ecg_band);
    high_freq_power = bandpower(ecg_centered, fs, high_freq_band);

    if fs/2 > 51
        powerline_power = bandpower(ecg_centered, fs, powerline_band);
    else
        powerline_power = 0;
    end

    % Normalized ratios
    quality.baseline_ratio = baseline_power / total_power;
    quality.ecg_ratio = ecg_power / total_power;
    quality.high_freq_ratio = high_freq_power / total_power;
    quality.powerline_ratio = powerline_power / total_power;

    % Simple estimated SNR
    noise_power = baseline_power + high_freq_power + powerline_power;
    quality.snr_estimate_db = 10 * log10(ecg_power / noise_power);

    % Quality label
    if quality.snr_estimate_db > 10 && quality.baseline_ratio < 0.15 && quality.high_freq_ratio < 0.20
        quality.label = "Good";
    elseif quality.snr_estimate_db > 5
        quality.label = "Moderate";
    else
        quality.label = "Poor";
    end

end