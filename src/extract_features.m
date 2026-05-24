function features_table = extract_features(beats, valid_r_locs, fs)

    num_beats = size(beats, 1);

    peak_amp = zeros(num_beats, 1);
    min_amp = zeros(num_beats, 1);
    peak_to_peak = zeros(num_beats, 1);
    mean_amp = zeros(num_beats, 1);
    std_amp = zeros(num_beats, 1);
    beat_energy = zeros(num_beats, 1);
    rms_value = zeros(num_beats, 1);
    qrs_width = zeros(num_beats, 1);

    dominant_freq = zeros(num_beats, 1);
    spectral_energy = zeros(num_beats, 1);
    low_band_power = zeros(num_beats, 1);
    high_band_power = zeros(num_beats, 1);

    rr_interval = zeros(num_beats, 1);
    heart_rate_bpm = zeros(num_beats, 1);

    for i = 1:num_beats

        beat = beats(i, :);

        %% Time-domain features
        peak_amp(i) = max(beat);
        min_amp(i) = min(beat);
        peak_to_peak(i) = peak_amp(i) - min_amp(i);
        mean_amp(i) = mean(beat);
        std_amp(i) = std(beat);
        beat_energy(i) = sum(beat.^2);
        rms_value(i) = rms(beat);

%% QRS width estimation

[~, r_index] = max(abs(beat));

search_window_sec = 0.12;
search_samples = round(search_window_sec * fs);

start_idx = max(1, r_index - search_samples);
end_idx = min(length(beat), r_index + search_samples);

local_qrs = beat(start_idx:end_idx);

local_qrs_abs = abs(local_qrs - median(local_qrs));

threshold = 0.25 * max(local_qrs_abs);

qrs_indices = find(local_qrs_abs >= threshold);

if isempty(qrs_indices)
    qrs_width(i) = 0.08;
else
    qrs_width_samples = qrs_indices(end) - qrs_indices(1) + 1;
    qrs_width(i) = qrs_width_samples / fs;
end

if qrs_width(i) < 0.04 || qrs_width(i) > 0.18
    qrs_width(i) = 0.08;
end

        %% Frequency-domain features
        N = length(beat);
        fft_beat = abs(fft(beat));
        f = (0:N-1) * (fs/N);

        half_idx = 1:floor(N/2);
        fft_half = fft_beat(half_idx);
        f_half = f(half_idx);

        spectral_energy(i) = sum(fft_half.^2);

        [~, max_idx] = max(fft_half);
        dominant_freq(i) = f_half(max_idx);

        low_band_idx = f_half >= 0.5 & f_half <= 15;
        high_band_idx = f_half > 15 & f_half <= 40;

        low_band_power(i) = sum(fft_half(low_band_idx).^2);
        high_band_power(i) = sum(fft_half(high_band_idx).^2);

        %% Physiological features
        if i == 1
            rr_interval(i) = NaN;
            heart_rate_bpm(i) = NaN;
        else
            rr_interval(i) = (valid_r_locs(i) - valid_r_locs(i-1)) / fs;
            heart_rate_bpm(i) = 60 / rr_interval(i);
        end

    end

    features_table = table( ...
        peak_amp, ...
        min_amp, ...
        peak_to_peak, ...
        mean_amp, ...
        std_amp, ...
        beat_energy, ...
        rms_value, ...
        qrs_width, ...
        dominant_freq, ...
        spectral_energy, ...
        low_band_power, ...
        high_band_power, ...
        rr_interval, ...
        heart_rate_bpm);

end