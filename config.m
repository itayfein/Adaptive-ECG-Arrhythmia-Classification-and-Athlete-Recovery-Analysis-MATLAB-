function cfg = config()

    cfg.project_name = "Adaptive ECG Signal Processing and Explainable Arrhythmia Classification";

    cfg.fs = 360;

    cfg.default_low_cutoff = 0.5;
    cfg.default_high_cutoff = 40;
    cfg.notch_freq = 50;
    cfg.filter_order = 4;

    cfg.baseline_power_threshold = 0.15;
    cfg.high_freq_power_threshold = 0.20;
    cfg.powerline_threshold = 0.10;

    cfg.min_peak_distance_sec = 0.25;
    cfg.peak_threshold_factor = 0.6;

    cfg.pre_R_window_sec = 0.25;
    cfg.post_R_window_sec = 0.45;

    cfg.train_ratio = 0.8;
    cfg.classifier_type = "SVM";

    cfg.save_figures = true;
    cfg.results_dir = "results";

end