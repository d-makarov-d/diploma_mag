classdef Layer < handle
    properties (Access = private)
        weights;
        biases;
        type;           % type of the layer, can be filter or neural
        TYPE_FILTER = 'filter';
        TYPE_NEURAL = 'neural';
    end
    properties (Access = public)
        name;       % name, as the layer was named when training
        in_len;         % length of vector of data, input in this layer
        out_len;        % length of result of this model application
    end
    methods (Access = public)
        function obj = Layer(variables, name)
            obj.name = name;
            if (length(variables) == 1)
                % only weights, means layer has "filter" type
                obj.type = obj.TYPE_FILTER;
                obj.biases = [];
                w = variables{1};
                w = w - min(w);
                w = w / max(w);
                w = 1 - w;
                obj.weights = w;
                obj.in_len = length(obj.weights);
                obj.out_len = length(obj.weights);
            else
                % means, layer is "neural"
                obj.type = obj.TYPE_NEURAL;
                if (isempty(find(size(variables{1}) == 1, 1)))
                    % means, first variable has no dimesions of size 1, so
                    % it is weights
                    obj.weights = variables{1};
                    obj.biases = variables{2};
                else
                    obj.weights = variables{2};
                    obj.biases = variables{1};
                end
                [obj.in_len, obj.out_len] = size(obj.weights);
            end
        end
        function res = apply(obj, data)
            % applies this layer to data, which can be a batch of rows
            % or a single row
            % data - must be a matrix of size [batch_size, in_len]
            % returns
            % res - matrix of size [batch_size, out_len]
            assert(size(data, 2) == obj.in_len);
            switch obj.type
                case obj.TYPE_FILTER
                    res = data .* obj.weights;
                case obj.TYPE_NEURAL
                    res = data * obj.weights + obj.biases;
            end
        end
        function [w, b] = getWB(obj)
            w = obj.weights;
            b = obj.biases;
        end
    end
end