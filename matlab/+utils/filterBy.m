function res = filterBy(sig, model)
% filters signal of arbitrary length by given trained model
% sig - signal, mkm/sec^2, must be a row
% model - trained model
% returns
% res - filtered signal, mkm/sec^2
    assert(size(sig, 1) == 1, 'signal must be a row');
    % make varible, multile to model length
    multiple_len = ceil(length(sig) ./ model.len) * model.len - length(sig);
    toFilter = [sig, zeros(1, multiple_len)];
    % "cut" to_filter in vectors of suiteble for model size
    toModel = reshape(toFilter, model.len, [])';
    filtered = model.apply(toModel);
    % put peases together
    res = reshape(filtered', [], length(toFilter));
    res(length(sig)+1:end) = [];
end