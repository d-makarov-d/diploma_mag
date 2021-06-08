fs = 62.5;

filters = {};
model = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');
layers = model.getLayers;
[w, ~] = layers{1}.getWB;
filters{1} = w;
model = utils.loadModel('patterns/models/stat_dry/0.model');
layers = model.getLayers;
[w, ~] = layers{1}.getWB;
filters{2} = w;
model = utils.loadModel('patterns/models/old.model');
layers = model.getLayers;
[w, ~] = layers{1}.getWB;
filters{3} = w;

hold on;

for i = 1% length(filters)
    y = filters{i}(1: length(filters{i})/2 + 1);
    x = linspace(0, fs/2, length(y));
    plot(x, y, 'LineWidth', 1.5);
end

xlabel('Frequancy, Hz')
ylabel('Spectral power')
legend('filter from noisy data', 'filter from clear sig', 'strict filter');
