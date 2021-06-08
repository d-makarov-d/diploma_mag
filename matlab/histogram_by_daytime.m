function [s_n, d_s_n, hours] = histogram_by_daytime(sigs, noises, sig_intervals, noise_intervals, T0)
    hours = 0:23;
    s_n = zeros(size(hours));
    d_s_n = zeros(size(hours));
    % hist = zeros(size(hours));
    for_hist = [];
    for h = hours
        t_s = datetime(sig_intervals(:,1) / (24*60*60) + T0, 'ConvertFrom', 'datenum');
        t_n = datetime(noise_intervals(:,1) / (24*60*60) + T0, 'ConvertFrom', 'datenum');
        is_sig = hour(t_s) == h;
        is_noise = hour(t_n) == h;
        [s_n(h + 1), ~, d_s_n(h+1)] = sig_noise(sigs(is_sig, :), noises(is_noise, :));
        % hist(h+1) = length(find(hour(t_s) == h & day(t_s) == 1));
        for_hist = [ for_hist ones(1, length(find(hour(t_s) == h & day(t_s) == 4))) * h];
    end
end