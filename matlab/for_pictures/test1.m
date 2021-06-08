% neural = utils.loadModel('patterns/models/neural_Nadam_30eph_0.00001lrate_rnd.model');
% deep = utils.loadModel('patterns/models/deep1h_Adamax_15eph_0.00003lrate_rnd.model');
default1 = utils.loadModel('patterns/models/default_Adadelta_200eph_0.00100lrate_nornd.model');
default2 = utils.loadModel('patterns/models/default_Adagrad_200eph_0.00100lrate_nornd.model');
default3 = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');
old = utils.loadModel('patterns/models/old.model');
dry = utils.loadModel('patterns/models/stat_dry/0.model');

[T, sig] = utils.readSignals('seismic_data/22890216.adb');
interval = T <= 1600;
T = T(interval);
sig = sig(interval);

neuralF = neural.applyAdjusted(sig);
% deepF = deep.applyAdjusted(sig);
% default1F = default1.applyAdjusted(sig);
% default2F = default2.applyAdjusted(sig);
default3F = default3.applyAdjusted(sig);
oldF = old.applyAdjusted(sig);
dryF = dry.applyAdjusted(sig);

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

trains_mask = false(size(sig));
for i=1:size(intervals, 1)
    trains_mask = trains_mask | (T >= intervals(i, 1) & T <= intervals(i, 2));
end

fprintf('unfiltered sig/noise = %.3f\n', calcSigNoise(sig, trains_mask));
% fprintf('deep sig/noise = %.3f\n', calcSigNoise(deepF, trains_mask));
fprintf('default sig/noise = %.3f\n', calcSigNoise(default3F, trains_mask));
% fprintf('neural sig/noise = %.3f\n', calcSigNoise(neuralF, trains_mask));
fprintf('old/noise = %.3f\n', calcSigNoise(oldF, trains_mask));
fprintf('dry/noise = %.3f\n', calcSigNoise(dryF, trains_mask));

hold on;
hSig = plot(T, sig, 'b');
hFiltered = plot(T, neuralF, 'r');

for i=1:size(intervals, 1)
    interv = intervals(i, :);
    rectangle('Position', [interv(1), -40, interv(2) - interv(1), 80], 'FaceColor', [0, 1, 0, 0.2]);
end

legend([hSig, hFiltered, fill(NaN, NaN, 'g')], {'изначальный сигнал', 'отфильтрованный сигнал', 'области с сигналом от поезда'});
ax = gca; ax.FontSize = 20;
f = gcf; f.Color = 'w';
xlabel('Время, сек.');
ylabel('Ускорение, мкм/сек^2');

ylim([-70, 70]);

function res = calcSigNoise(sig, mask)
    tr = sig(mask);
    ntr = sig(~mask);
    res = std(tr) / std(ntr);
end