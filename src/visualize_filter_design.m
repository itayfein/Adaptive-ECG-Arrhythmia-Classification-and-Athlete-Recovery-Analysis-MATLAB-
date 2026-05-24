function filter_analysis = visualize_filter_design(fs, filter_info)
%VISUALIZE_FILTER_DESIGN Visualize ECG preprocessing filter behavior.

    low_cutoff = filter_info.low_cutoff;
    high_cutoff = filter_info.high_cutoff;
    filter_order = filter_info.filter_order;

    %% Design bandpass Butterworth filter
    [b_band, a_band] = butter(filter_order, ...
        [low_cutoff high_cutoff] / (fs/2), ...
        'bandpass');

    %% Frequency response
    figure;
    freqz(b_band, a_band, 2048, fs);
    title('ECG Bandpass Filter Frequency Response');

    %% Pole-zero map
    figure;
    zplane(b_band, a_band);
    title('Bandpass Filter Pole-Zero Map');

    %% Magnitude response data
    [H, f] = freqz(b_band, a_band, 2048, fs);
    magnitude_db = 20*log10(abs(H));

    figure;
    plot(f, magnitude_db, 'LineWidth', 1.5);
    grid on;
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    title('Bandpass Filter Bode Magnitude Response');
    xlim([0 100]);

    hold on;
    xline(low_cutoff, '--', 'Low Cutoff');
    xline(high_cutoff, '--', 'High Cutoff');

    %% Optional notch filter
    notch_applied = filter_info.notch_applied;

    if notch_applied
        wo = 50 / (fs/2);
        bw = wo / 35;

        [b_notch, a_notch] = iirnotch(wo, bw);

        figure;
        freqz(b_notch, a_notch, 2048, fs);
        title('50 Hz Notch Filter Frequency Response');

        figure;
        zplane(b_notch, a_notch);
        title('50 Hz Notch Filter Pole-Zero Map');
    end

    %% Text summary
    filter_analysis = struct();

    filter_analysis.bandpass_range_hz = [low_cutoff high_cutoff];
    filter_analysis.filter_order = filter_order;
    filter_analysis.preserved_frequency_band = ...
        sprintf('ECG components between %.1f and %.1f Hz are preserved.', low_cutoff, high_cutoff);

    filter_analysis.removed_low_frequency_noise = ...
        sprintf('Frequencies below %.1f Hz are attenuated to reduce baseline wander.', low_cutoff);

    filter_analysis.removed_high_frequency_noise = ...
        sprintf('Frequencies above %.1f Hz are attenuated to reduce muscle and high-frequency noise.', high_cutoff);

    if notch_applied
        filter_analysis.powerline_filtering = ...
            '50 Hz notch filtering is applied to suppress powerline interference.';
    else
        filter_analysis.powerline_filtering = ...
            'No notch filter was applied because powerline interference was not significant.';
    end

    disp("=== Filter Design Analysis ===");
    disp(filter_analysis);

end