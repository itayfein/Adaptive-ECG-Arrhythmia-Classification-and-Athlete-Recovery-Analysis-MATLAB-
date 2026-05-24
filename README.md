# Adaptive ECG Arrhythmia Classification and Athlete Recovery Analysis (MATLAB)

## Overview

This project implements an adaptive ECG signal-processing and arrhythmia-analysis pipeline in MATLAB.

The system performs:

- ECG signal quality assessment
- Adaptive digital filtering
- Beat segmentation
- Feature extraction
- Machine-learning-based arrhythmia classification
- Athlete-oriented post-exercise recovery analysis
- Interactive graphical user interface (GUI)

The project is designed around the MIT-BIH Arrhythmia Database and focuses on physiological interpretation for athlete monitoring and recovery analysis.

---

# Main Features

## ECG Signal Processing

- Baseline wander reduction
- High-frequency noise suppression
- Adaptive bandpass filtering
- Optional notch filtering
- Signal quality estimation

---

## Arrhythmia Detection

Binary machine-learning classifier:

-Normal
-Abnormal

Supported arrhythmia labels:

| Label | Description |
|---|---|
| N | Normal beat |
| A | Atrial premature beat |
| V | Premature ventricular contraction |
| F | Fusion beat |
| L | Left bundle branch block beat |
| R | Right bundle branch block beat |

---

## Athlete Recovery Metrics

The system computes:

- Average heart rate
- Heart-rate range
- RR interval statistics
- RMSSD
- SDNN
- QRS width estimation
- Abnormal beat density
- Recovery trend estimation

Example report:

```text
Average Heart Rate: 75.8 bpm
RMSSD: 0.063 sec — Good HRV
Abnormal Beat Density: 1.13 beats/min
Recovery Trend: Moderate heart-rate recovery
```

---

# GUI Features

The GUI includes:

- MIT-BIH record selection
- Custom ECG file upload
- ECG visualization
- Heart-rate recovery visualization
- Athlete recovery report
- Dedicated filter-analysis window

Filter-analysis window includes:

- Frequency response
- Bode magnitude response
- Phase response
- Pole-zero map
- Filter interpretation

---

# Project Structure

```text
Adaptive-ECG-Arrhythmia-Classification-MATLAB/
│
├── app/
│   └── athlete_ecg_gui.m
│
├── data/
│   └── mit-bih-arrhythmia-database-1.0.0/
│
├── src/
│   ├── classification/
│   │   ├── predict_arrhythmia_binary.m
│   │   └── trainedModel_binary.mat
│   │
│   ├── adaptive_filter_engine.m
│   ├── analyze_post_exercise_metrics.m
│   ├── extract_features.m
│   ├── generate_athlete_report.m
│   ├── signal_quality_assessment.m
│   ├── visualize_filter_design.m
│   └── ...
│
├── tests/
│   ├── run_binary_detection_on_record.m
│   └── evaluate_model_on_records.m
│
├── results/
│   ├── metrics/
│   ├── models/
│   └── reports/
│
└── README.md
```

---

# Machine Learning Pipeline

## Dataset

Dataset source:

- MIT-BIH Arrhythmia Database

Records used:

```text
100, 101, 106, 109, 119, 200, 207, 208, 213, 221, 233
```

---

## Feature Extraction

Extracted features include:

### Time-domain Features

- Peak amplitude
- Minimum amplitude
- Peak-to-peak amplitude
- Mean amplitude
- Standard deviation
- Beat energy
- RMS value
- QRS width

### Frequency-domain Features

- Dominant frequency
- Spectral energy
- Low-band power
- High-band power

### Physiological Features

- RR interval
- Heart rate

---

## Classification

Model type:

- Bagged Trees Ensemble

Training environment:

- MATLAB Classification Learner App

---

# Filter Design

## Adaptive Bandpass Filter

The filtering stage is adaptive and automatically adjusts filtering behavior according to the estimated ECG signal quality and detected noise characteristics.

The system evaluates:

- baseline wander level
- high-frequency noise level
- powerline interference level
- estimated ECG signal-to-noise ratio (SNR)

Based on these measurements, the filter dynamically adapts:

- high-pass filtering behavior
- low-pass filtering behavior
- optional notch filtering
- filtering decisions and interpretation

Typical ECG passband:

```text
0.5 Hz – 40 Hz
```

The adaptive filtering stage:

- suppresses baseline drift
- reduces muscle noise
- attenuates high-frequency interference
- optionally removes powerline interference

---

# Running the Project

## Launch GUI

From MATLAB:

```matlab
cd app
athlete_ecg_gui
```

---

## Run Binary Detection Script

```matlab
cd tests
run_binary_detection_on_record
```

---

## Evaluate Multiple Records

```matlab
evaluate_model_on_records
```

---

# Custom ECG Files

The GUI supports loading:

- CSV
- TXT
- MAT

Users can upload ECG recordings directly through the GUI.

---

# Example Output

```text
=== Athlete Post-Exercise ECG Report ===

Average Heart Rate: 62.3 bpm
RMSSD: 0.065 sec — Good HRV
QRS Width: 0.079 sec — Normal QRS width
Abnormal Beat Density: Low
Recovery Trend: Moderate heart-rate recovery

Overall Assessment:
Normal post-exercise recovery pattern
```

---

# Future Work

Potential future improvements:

- Real-time ECG streaming
- Arduino / ESP32 integration
- Wearable athlete monitoring
- Multi-class arrhythmia classification
- Deep learning models
- HRV trend analysis
- Cloud-based monitoring dashboard
- MATLAB App Designer migration

---

# Requirements

## MATLAB Toolboxes

Required:

- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

Recommended:

- DSP System Toolbox

---

# Authors

Adaptive ECG Arrhythmia Classification and Athlete Recovery Analysis Project

Implemented in MATLAB for biomedical signal processing and athlete-oriented physiological monitoring.
