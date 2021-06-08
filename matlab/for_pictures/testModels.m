% neural = utils.loadModel('patterns/models/neural_Nadam_30eph_0.00001lrate_rnd.model');
% neural = utils.loadModel('patterns/models/neural_Adam_30eph_0.00001lrate_rnd.model');
% deep = utils.loadModel('patterns/models/deep1h_Adamax_15eph_0.00003lrate_rnd.model');
default1 = utils.loadModel('patterns/models/default_Adadelta_200eph_0.00100lrate_nornd.model');
default2 = utils.loadModel('patterns/models/default_Adagrad_200eph_0.00100lrate_nornd.model');
default3 = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');
def_dry = utils.loadModel('patterns/models/stat_dry/0.model');
old = utils.loadModel('patterns/models/old.model');

[T, sig] = utils.readSignals('seismic_data/22890216.adb');

% neuralF = neural.applyAdjusted(sig);
% deepF = deep.applyAdjusted(sig);
% default1F = default1.applyAdjusted(sig);
default2F = default2.applyAdjusted(sig);
default3F = default3.applyAdjusted(sig);
oldF = old.applyAdjusted(sig);
dryF = def_dry.applyAdjusted(sig);

utils.seismoplot(T, sig, 70, 7, 'b');
utils.seismoplot(T, dryF, 70, 7, 'r');
utils.seismoplot(T, oldF, 70, 7, 'g');