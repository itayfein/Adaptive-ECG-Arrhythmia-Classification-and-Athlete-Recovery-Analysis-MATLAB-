function report = generate_athlete_report(metrics)

    report = strings(0,1);

    report(end+1) = "=== Athlete Post-Exercise ECG Report ===";
    report(end+1) = "";

    report(end+1) = sprintf("Average Heart Rate: %.1f bpm — average post-exercise heart rate.", metrics.average_hr_bpm);
    report(end+1) = sprintf("Heart Rate Range: %.1f–%.1f bpm.", metrics.min_hr_bpm, metrics.max_hr_bpm);

    report(end+1) = sprintf("RMSSD: %.3f sec — %s.", metrics.rmssd_sec, metrics.hrv_status);
    report(end+1) = sprintf("SDNN: %.3f sec — heart-rate variability over the recording.", metrics.sdnn_sec);

    report(end+1) = sprintf("QRS Width: %.3f sec — %s.", metrics.average_qrs_width_sec, metrics.qrs_status);

    report(end+1) = sprintf("Abnormal Beats: %d out of %d beats.", metrics.abnormal_beats, metrics.total_beats);
    report(end+1) = sprintf("Abnormal Beat Density: %.2f beats/min — %s.", metrics.abnormal_beats_per_min, metrics.abnormal_density_label);

    report(end+1) = sprintf("Initial HR: %.1f bpm.", metrics.initial_hr_bpm);
    report(end+1) = sprintf("Final HR: %.1f bpm.", metrics.final_hr_bpm);
    report(end+1) = sprintf("HR Recovery Drop: %.1f bpm — %s.", metrics.hr_recovery_drop_bpm, metrics.recovery_trend);

    report(end+1) = "";
    report(end+1) = "Overall Assessment:";
    report(end+1) = metrics.overall_recovery_status;

end