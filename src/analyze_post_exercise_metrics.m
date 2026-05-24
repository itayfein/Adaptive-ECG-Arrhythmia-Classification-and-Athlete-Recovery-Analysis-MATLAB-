function metrics = analyze_post_exercise_metrics(features_table, predicted_labels, fs)
%ANALYZE_POST_EXERCISE_METRICS Compute athlete post-exercise ECG metrics.

    rr = features_table.rr_interval;
    hr = features_table.heart_rate_bpm;
    qrs = features_table.qrs_width;

    valid_rr = rr(~isnan(rr));
    valid_hr = hr(~isnan(hr));
    valid_qrs = qrs(~isnan(qrs));

    metrics.average_hr_bpm = mean(valid_hr);
    metrics.max_hr_bpm = max(valid_hr);
    metrics.min_hr_bpm = min(valid_hr);

    %% Recovery trend analysis

num_hr = length(valid_hr);

first_window = valid_hr(1:round(0.2*num_hr));
last_window = valid_hr(round(0.8*num_hr):end);

metrics.initial_hr_bpm = mean(first_window);
metrics.final_hr_bpm = mean(last_window);
metrics.hr_recovery_drop_bpm = metrics.initial_hr_bpm - metrics.final_hr_bpm;

if metrics.hr_recovery_drop_bpm > 15
    metrics.recovery_trend = "Strong heart-rate recovery";
elseif metrics.hr_recovery_drop_bpm > 5
    metrics.recovery_trend = "Moderate heart-rate recovery";
elseif metrics.hr_recovery_drop_bpm >= 0
    metrics.recovery_trend = "Weak heart-rate recovery";
else
    metrics.recovery_trend = "Heart rate increased during recording";
end

    metrics.sdnn_sec = std(valid_rr);
    metrics.rmssd_sec = sqrt(mean(diff(valid_rr).^2));

    metrics.average_qrs_width_sec = mean(valid_qrs);
    metrics.max_qrs_width_sec = max(valid_qrs);

    metrics.total_beats = height(features_table);
    metrics.normal_beats = sum(predicted_labels == "Normal");
    metrics.abnormal_beats = sum(predicted_labels == "Abnormal");

    duration_min = sum(valid_rr) / 60;
    metrics.abnormal_beats_per_min = metrics.abnormal_beats / duration_min;

    if metrics.abnormal_beats_per_min < 1
        metrics.abnormal_density_label = "Low";
    elseif metrics.abnormal_beats_per_min < 5
        metrics.abnormal_density_label = "Moderate";
    else
        metrics.abnormal_density_label = "High";
    end

    if metrics.average_qrs_width_sec < 0.10
        metrics.qrs_status = "Normal QRS width";
    elseif metrics.average_qrs_width_sec < 0.12
        metrics.qrs_status = "Borderline QRS widening";
    else
        metrics.qrs_status = "Possible QRS widening";
    end

    if metrics.rmssd_sec > 0.04
        metrics.hrv_status = "Good HRV";
    elseif metrics.rmssd_sec > 0.02
        metrics.hrv_status = "Moderate HRV";
    else
        metrics.hrv_status = "Low HRV";
    end

    if metrics.abnormal_density_label == "Low" && metrics.hrv_status ~= "Low HRV"
        metrics.overall_recovery_status = "Normal post-exercise recovery pattern";
    elseif metrics.abnormal_density_label == "Moderate"
        metrics.overall_recovery_status = "Moderate abnormal beat activity after exercise";
    else
        metrics.overall_recovery_status = "Elevated abnormal beat activity or reduced recovery stability";
    end

end