function [sigs, noises, sig_intervals, noise_intervals] = sig_noise_calc(T, sig, intervals)
% finds intrvals with noise and with signal of same length
% T - timeline
% sig - signal
% intervals - matrix (N, 2), where N - intervals count (:, 1) -start, 
%             (:, 2) - end
%
% sigs - signal parts
% noises - noise parts
% sig_intervals - start and stop times of signal parts
% noise_intervals - start and stop times of noise parts
    noise = zeros(size(intervals, 1) + 1, size(intervals, 2));
    for i = 2:size(intervals, 1)
        noise(i, :) = [intervals(i-1, 2) intervals(i, 1)];
    end
    noise(1, :) = [0, intervals(1, 1)];
    noise(end, :) = [intervals(end, 2), 1600];

    sample_len = 38; % sec

    sig_intervals = zeros(size(intervals));
    noise_intervals = [];

    for i = 1:size(intervals, 1)
        int = intervals(i, :);
        int_len = int(2) - int(1);
        shift = (int_len - sample_len) / 2;
        sig_intervals(i, :) = [int(1) + shift, int(2) - shift];
    end
    for i = 1:size(noise, 1)
        int = noise(i, :);
        int_len = int(2) - int(1);
        if (int_len > sample_len * 10)
            v = ceil(int_len / ( sample_len * 1.5 ));
            internal_len = int_len / v;
            for i_in = 1:v
                int_st = int(1) + internal_len * (i_in - 1) + (internal_len - sample_len)/2;
                noise_intervals(end+1, :) = [int_st, int_st + sample_len];
            end
        elseif (int_len > sample_len * 1.5)
            shift = (int_len - sample_len) / 2;
            noise_intervals(end+1, :) = [int(1) + shift, int(2) - shift];
        end
    end

    utils.info_plot({}, {sig_intervals, noise_intervals});

    int_len = length(sig(T >= sig_intervals(1, 1) & T <= sig_intervals(1, 2)));
    sigs = zeros(size(sig_intervals, 1), int_len);
    noises = zeros(size(noise_intervals, 1), int_len);
    for i=1:size(sig_intervals, 1)
        is = find(T >= sig_intervals(i, 1) & T < sig_intervals(i, 2));
        sigs(i, :) = sig(is:is + int_len - 1);
    end

    for i=1:size(noise_intervals, 1)
        is = find(T >= noise_intervals(i, 1) & T < noise_intervals(i, 2));
        noises(i, :) = sig(is:is + int_len - 1);
    end
end

