function model = loadModel(path)
% Decodes model (.model file) to Model object
% path - path to .model file with weights and biases
% returns
% model - Model object
    fid = fopen(path);
    tline = fgetl(fid);
    variables = {};     % cell arr of actual weights or biases
    variable = [];      % struct for current variable
    model = utils.Model();
    name = '';
    while ischar(tline)
        if (~strcmp(tline, ''))
            % check if it is a variable name
            match = regexp(tline, '^[^ \[\]]+$', 'match');
            if (~isempty(match))
                saveLayer();
                name = tline;
            else
                if (isfield(variable, 'ndims'))
                    % means, the variable is not empty
                    [vals, dim] = readRow(tline);
                    variable.data = appendMatrix(variable.data, dim, vals);
                else
                    % means, that the variable is empty
                    variable.ndims = getDims(tline);
                    variable.data = cell(1, variable.ndims);
                    [vals, dim] = readRow(tline);
                    variable.data = appendMatrix(variable.data, dim, vals);
                end
                if (dim == variable.ndims)
                    % means, the end of the variable, need to start new
                    % one
                    variables{end+1} = variable.data{1};
                    variable = [];
                end
            end
        end
        
        tline = fgetl(fid);
    end
    saveLayer();
    
    function saveLayer()
        % save read layer, if any
        if (~isempty(variables))
            model.addLayer(utils.Layer(variables, name));
            variables = {};
            variable = [];
        end
    end
end

function dims = getDims(var)
    % returns number of dimensions, which can be calculated by the count of
    % "[" in the first row of "numpy" print
    dims = 0;
    ptr = regexp(var, '[', 'once');
    while var(ptr + dims) == '['
        dims = dims  + 1;
    end
end

function dims = getClosingDims(var)
    % works the same way, as getDims, but gets closing dimensions of a row
    var = flip(var);
    dims = 0;
    ptr = regexp(var, ']', 'once');
    while var(ptr + dims) == ']'
        dims = dims  + 1;
    end
end

function [vals, dim] = readRow(row)
    % parses an array row, and returns it's values as a vector, and the
    % dimension it is closing.
    dim = getClosingDims(row);
    strings = split(row, {' ', '[', ']'});
    % delete empty values because of several spaces and brackets in row
    strings(arrayfun(@(x) isempty(x{1}), strings)) = [];
    vals = arrayfun(@(x) str2double(x{1}), strings)';
end

function mat = appendMatrix(mat, dim, slice)
    % recursive function, folding dimensions till specified dim
    assert(length(mat) >= dim, ...
        'dimension must be present in matrix representation');
    % slices to last dimension
    if (dim > 1)
        mat = appendMatrix(mat, dim-1, slice);
        mat{end - dim + 1} = cat(dim+1, mat{end - dim + 1}, mat{end - dim + 2});
        mat{end - dim + 2} = [];
    else
        mat{end} = cat(dim, mat{end}, slice);
    end
end