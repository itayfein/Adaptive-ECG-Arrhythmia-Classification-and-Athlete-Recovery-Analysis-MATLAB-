function [ecg_signal, fs, ann_samples, ann_symbols] = load_mitbih_record_direct(record_name)
%LOAD_MITBIH_RECORD_DIRECT Load MIT-BIH ECG signal directly without WFDB.
%
% This function is designed for MIT-BIH records stored in format 212.
%
% Inputs:
%   record_name - string, for example '100'
%
% Outputs:
%   ecg_signal  - first ECG channel
%   fs          - sampling frequency
%   ann_samples - annotation sample locations
%   ann_symbols - simplified annotation symbols

    record_name = char(record_name);

    database_path = '../data/mit-bih-arrhythmia-database-1.0.0';

    hea_file = fullfile(database_path, [record_name '.hea']);
    dat_file = fullfile(database_path, [record_name '.dat']);
    atr_file = fullfile(database_path, [record_name '.atr']);

    %% Sampling frequency
    header_text = fileread(hea_file);
    header_lines = splitlines(header_text);
    first_line = strsplit(strtrim(header_lines{1}));
    fs = str2double(first_line{3});

    %% Read ECG signal from MIT-BIH format 212
    fid = fopen(dat_file, 'r');

    if fid == -1
        error('Could not open DAT file.');
    end

    data = fread(fid, inf, 'uint8');
    fclose(fid);

    data = data(:);

    num_samples = floor(length(data) / 3) * 2;

    sig1 = zeros(num_samples/2, 1);
    sig2 = zeros(num_samples/2, 1);

    idx = 1;

    for i = 1:3:length(data)-2

        byte1 = data(i);
        byte2 = data(i+1);
        byte3 = data(i+2);

        sample1 = byte1 + bitshift(bitand(byte2, 15), 8);
        sample2 = bitshift(byte3, 4) + bitshift(bitand(byte2, 240), -4);

        if sample1 >= 2048
            sample1 = sample1 - 4096;
        end

        if sample2 >= 2048
            sample2 = sample2 - 4096;
        end

        sig1(idx) = sample1;
        sig2(idx) = sample2;

        idx = idx + 1;
    end

    ecg_signal = sig1;

    %% Read annotations from MIT-BIH .atr file

    [ann_samples, ann_symbols] = read_mitbih_annotations_direct(atr_file);

    fprintf('Loaded MIT-BIH record directly: %s\n', record_name);
    fprintf('Sampling frequency: %.0f Hz\n', fs);
    fprintf('Signal length: %d samples\n', length(ecg_signal));
    fprintf('Annotations loaded: %d\n', length(ann_samples));

end