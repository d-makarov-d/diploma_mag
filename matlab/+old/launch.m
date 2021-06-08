% old treshold 0.2
clear;

filter = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');
dry = utils.loadModel('patterns/models/stat_dirty/0.model');
old_f = utils.loadModel('patterns/models/old.model');
[T, sig] = utils.readSignals('seismic_data/covid_time/AZT-20201024T083856Z-001/AZT/AZT_AZT_200317_2289000');
% [T, sig] = utils.readSignals('seismic_data/22890216.adb');

sig = utils.anti_eject(sig, T);

% [~, x_a_dry, a_dry] = old.filtr_integral(T, sig, dry, 0.06);
[~, x_a_filt, a_filt] = old.filtr_integral(T, sig, filter, 0.2);
% [~, x_a_old, a_old] = old.filtr_integral(T, sig, old_f, 0.06);

m = a_dry > 0.1434;
a_dry(m) = NaN;
a_filt(m) = NaN;

figure();
hold on;
% plot(x_a_dry, a_dry ./ max(a_dry), 'LineWidth', 1);
plot(x_a_filt, a_filt ./ max(a_filt), 'LineWidth', 1);
% plot(x_a_old, a_old ./ max(a_old), 'LineWidth', 1);

legend({'dry', 'noise', 'old'});
