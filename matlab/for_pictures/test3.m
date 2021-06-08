clear;
[T, sig] = utils.readSignals('seismic_data/22890216.adb');
interval = T <= 1600;
T = T(interval);
sig = sig(interval);

intervals = [...
    48.59, 124.4; ...
    157.5, 201.3; ...
    233.9, 286.5; ...
    343, 385.5; ...
    410.8, 471.8; ...
    548.1, 636.6; ...
    714.5, 801.9; ...
    893.2, 976.9; ...
    1092, 1121; ...
    1230, 1274; ...
    1418, 1480 ];

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
    noises(end+1, :) = sig(is:is + int_len - 1);
end

avg_sig = mean(sigs);
avg_noise = mean(noises);

fs = 62.5;
spect = abs(fft(avg_sig)) ./ abs(fft(avg_noise));
% spect = spect ./ max(spect);
y = spect(1: length(spect)/2 + 1);
x = linspace(0, fs/2, length(y));
plot(x, y, 'LineWidth', 2);