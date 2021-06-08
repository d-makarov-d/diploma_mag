clear;
[T, sig, ~, T0] = utils.readSignals('seismic_data/covid_time/AZT-20201024T083856Z-001/AZT/AZT_AZT_200317_2289000');
sig = utils.anti_eject(sig, T);

filter = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');

[ints] = utils.detect_signals(T, sig, filter);

filtered = filter.applyAdjusted(sig);
mask = ints.getAsMask(T);
intervals = ints.getAsObjects();

noise_level = std(sig(~mask));

ampls = zeros(1, length(intervals));
for i = 1:length(ampls)
    ampls(i) = amplitude_by_phse(intervals(i));
end

fprintf('std noise level %.2f\n', noise_level);
fprintf('signal level %.2f +- %.2f\n', mean(ampls, 'omitnan'), std(ampls, 'omitnan'));
