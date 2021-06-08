%% test simple filter layer import
expected_w = [1, 2, 3];
layers = utils.loadModel('+tests/test_models/simple_w.model').getLayers();
[w, ~] = layers{1}.getWB();
assert(isequal(expected_w, w), 'incorrect weight');

%% test simple neural layer import
expected_w = [11, 12, 13; 21, 22, 23;];
expected_b = [1, 2, 3];
layers = utils.loadModel('+tests/test_models/simple_wb.model').getLayers();
[w, b] = layers{1}.getWB();
assert(isequal(expected_w, w), 'incorrect weight');
assert(isequal(expected_b, b), 'incorrect biases');

%% test multidymentional imports
expected_w(:, :, 1) = [111., 112, 113; ...
                       121., 122, 123; ...
                       131., 132, 133; ...
                       141., 142, 143];

expected_w(:, :, 2) = [211., 212, 213; ...
                       221., 222, 223; ...
                       231., 232, 233; ...
                       241., 242, 243];

expected_b = zeros(4,5,3,2);        % equivalint to numpy.zeros([2,3,4,5])

layers = utils.loadModel('+tests/test_models/multidym.model').getLayers();
[w, b] = layers{1}.getWB();
assert(isequal(expected_w, w), 'incorrect weight');
assert(isequal(expected_b, b), 'incorrect biases');