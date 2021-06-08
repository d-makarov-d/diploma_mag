clear;
% [T, sig] = utils.readSignals('seismic_data/covid_time/AZT-20201024T083856Z-001/AZT/AZT_AZT_200317_2289000');
[T, sig, ~, T0] = utils.readSignals('seismic_data/AZT_190506', false, '.+[0-4].\.adb');
% [T, sig, ~, T0] = utils.readSignals('seismic_data/covid_time/AZT-20201024T083856Z-001/AZT', true ,'.+AZT_AZT_200317_228900[0-9].+\.adb');
sig = utils.anti_eject(sig, T);

filter = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');

[ints] = utils.detect_signals(T, sig, filter);

intervals = ints.getAsIntervals();

[sigs, noises, s, n] = sig_noise_calc(T, filter.applyAdjusted(sig), intervals);

% signal - noise by time
% divide signals and noises by 30 - min intervals
[s_n, d_s_n, hrs] = histogram_by_daytime(sigs, noises, s, n, T0);
hold on
for h = hrs
    x = [h h+1 h+1 h];
    y = [[s_n(h+1) s_n(h+1)] + d_s_n(h+1) [s_n(h+1) s_n(h+1)] - d_s_n(h+1)];
    
    fill(x, y, 'r')
    plot(h + 0.5, s_n(h+1), 'xk', 'LineWidth', 6.0)
end
xticks([hrs 24])
xlim([0, 24]);
ylim([0, 3]);
title(sprintf('Signal - noise relation, depending on day time\nrec. %s -- %s', datestr(T0), datestr(T0 + T(end) / (24*60*60))))
legend({'signal - noise std.dev', 'signal - noise'});
xlabel('Time of the day, hours');
ylabel('Signal - noise relation');
set(gca, 'FontSize', 15);
set(gcf, 'Color', 'w');


[~, spec] = sig_noise(sigs, noises);

