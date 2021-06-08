function [ampl, spectral, dev_ampl] = sig_noise(sigs, noises)
% calculates signal - noise dependency
% sigs - signal parts
% noises - noise parts
%
% ampl - overall amplitude signal - noise
% spectral - averaged spectral signal - noise
    noise_levels = zeros(1, size(noises, 1));
    sig_levels = zeros(1, size(sigs, 1));
    for i = 1:size(sigs, 1)
        % calculate signal level by mean of signal envelope
        sig_levels(i) = mean(envelope(sigs(i, :)));
    end
    
    for i = 1:size(noises, 1)
        % calculate signal level by mean of signal envelope
        noise_levels(i) = mean(envelope(noises(i, :)));
    end
    
    x = mean(sig_levels);
    dx = std(sig_levels);
    y = mean(noise_levels);
    dy = std(noise_levels);
    ampl = x / y;
    dev_ampl = sqrt((dx / y) ^ 2 + (x ./ y ./ y * dy) ^ 2);
    
    sig_specs = abs(fft(sigs, size(sigs, 2), 2));
    noise_specs = abs(fft(noises, size(noises, 2), 2));
    s_sig_avg = mean(sig_specs, 1);
    s_noise_avg = mean(noise_specs, 1);
    spectral = s_sig_avg ./ s_noise_avg;
    std_sig = std(sig_specs, 1);
    
    peak_mask = 50:58;
    x = mean(s_sig_avg(peak_mask));
    dx = std(mean(sig_specs(:, peak_mask), 2));
    y = mean(s_noise_avg(peak_mask));
    dy = std(mean(noise_specs(:, peak_mask), 2));
    % ampl = x / y;
    % dev_ampl = sqrt((dx / y) ^ 2 + (x ./ y ./ y * dy) ^ 2);
    % drawAvgDev(s_sig_avg, std_sig);
end

function drawAvgDev(s_sig_avg, std_sig)
    fs = 62.5;
    len = length(std_sig)/2 + 1;
    x = linspace(0, fs/2, len);
    dev = std_sig(1:len);
    avg = s_sig_avg(1:len);
    
    sDev = trapz(dev);
    hold on;
    pDev = fill([x, flip(x)], [avg + dev/2, flip(avg - dev/2)], ...
        'r', 'FaceAlpha', 0.7, 'LineStyle', 'none');
    plot(x, avg);
end

