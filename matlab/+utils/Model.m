classdef Model < handle
    properties (Access = public)
        len;        % length of a vector of data, operated by this model
    end
    properties (Access = private)
        layers;     % vector of layers, forming the model
    end
    methods (Access = public)
        function obj = Model()
            % constructor, defines empty layers vector
            obj.layers = [];
            obj.len = -1;
        end
        function addLayer(obj, layer)
            % adds new layer
            assert(isa(layer, 'utils.Layer'), ...
                sprintf('expected utils.Layer, found %s', class(layer)));
            if (obj.len == -1)
                % initialize model length by the first layer passed
                obj.len = layer.in_len;
            end
            obj.layers{end + 1} = layer;
        end
        function res = apply(obj, data)
            % sequentially applies layers to given data
            % move to fourier
            data = fft(data, size(data, 2), 2);
            res = data;
            for i=1:length(obj.layers)
                res = obj.layers{i}.apply(res);
            end
            res = real(ifft(res, size(res, 2), 2));
        end
        function res = applyAdjusted(obj, sig)
            N = ceil(length(sig) ./ obj.len);
            multiple_len = N * obj.len - length(sig);
            toFilter = [fft(sig), zeros(1, multiple_len)];
            toAppl = reshape(toFilter, [], obj.len);
            res = toAppl;
            for i=1:length(obj.layers)
                res = obj.layers{i}.apply(res);
            end
            res = reshape(res, [], length(toFilter));
            res(length(sig)+1:end) = [];
            res = real(ifft(res));
        end
        function layers = getLayers(obj)
            layers = obj.layers;
        end
    end
end