function [beats, valid_r_locs, time_axis] = segment_beats(ecg_signal, r_locs, fs, cfg)
%SEGMENT_BEATS Segment ECG signal into individual beats around R-peaks.
%
% Inputs:
%   ecg_signal - filtered ECG signal
%   r_locs     - R-peak sample locations
%   fs         - sampling frequency [Hz]
%   cfg        - configuration struct
%
% Outputs:
%   beats        - matrix of segmented beats
%                  each row is one beat
%   valid_r_locs - R-peak locations used for valid segments
%   time_axis    - time vector around each R-peak

    ecg_signal = ecg_signal(:);

    pre_samples = round(cfg.pre_R_window_sec * fs);
    post_samples = round(cfg.post_R_window_sec * fs);

    beat_length = pre_samples + post_samples + 1;

    beats = [];
    valid_r_locs = [];

    for i = 1:length(r_locs)

        start_idx = r_locs(i) - pre_samples;
        end_idx = r_locs(i) + post_samples;

        if start_idx >= 1 && end_idx <= length(ecg_signal)
            beat = ecg_signal(start_idx:end_idx);
            beats = [beats; beat'];
            valid_r_locs = [valid_r_locs; r_locs(i)];
        end

    end

    time_axis = (-pre_samples:post_samples) / fs;

end