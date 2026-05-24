function [ann_samples, ann_symbols] = read_mitbih_annotations_direct(atr_file)

    fid = fopen(atr_file, 'r');
    if fid == -1
        error('Could not open ATR file.');
    end

    bytes = fread(fid, inf, 'uint8');
    fclose(fid);

    ann_samples = [];
    ann_symbols = strings(0);

    sample_counter = 0;
    i = 1;

    code_to_symbol = containers.Map( ...
        [1 2 3 4 5 6 7 8 9 10 11 12 13 34], ...
        {'N','L','R','a','V','F','J','A','S','E','j','/','Q','f'} );

    while i <= length(bytes)-1

        b1 = bytes(i);
        b2 = bytes(i+1);

        interval = double(b1) + bitshift(double(bitand(b2, 3)), 8);
        ann_type = bitshift(double(b2), -2);

        if ann_type == 0
            break;
        end

        if ann_type == 59
            % SKIP annotation: skip next 4 bytes
            i = i + 6;
            continue;
        elseif ann_type == 60 || ann_type == 61 || ann_type == 62
            % NUM, SUB, CHN
            i = i + 2;
            continue;
        elseif ann_type == 63
            % AUX annotation: interval stores number of aux bytes
            aux_len = interval;
            skip_bytes = 2 + aux_len;
            if mod(aux_len,2) == 1
                skip_bytes = skip_bytes + 1;
            end
            i = i + skip_bytes;
            continue;
        end

        sample_counter = sample_counter + interval;

        if isKey(code_to_symbol, ann_type)
            ann_samples(end+1,1) = sample_counter + 1; % MATLAB indexing
            ann_symbols(end+1,1) = string(code_to_symbol(ann_type));
        end

        i = i + 2;
    end
end