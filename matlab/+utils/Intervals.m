% Class, holdig intervals of signal
classdef Intervals < handle
    properties (Access = private)
        layers = [];     % list of layers
    end
    properties (Constant)
        TYPES = struct( ...         % Interval types
            'undef', 'undefined', ...
            't1', 'type_1', ...
            't2', 'type_2' ...
        );
    end
    methods (Access = public)
        function addPart(obj, sig, env, T, type)
            if (nargin == 4)
                type = obj.TYPES.undef;
            end
            obj.layers(end+1).sig = sig;
            obj.layers(end).T = T - T(1);
            obj.layers(end).int = [T(1), T(end)];
            obj.layers(end).env = env;
            obj.layers(end).type = type;
        end
        
        function addInterval(obj, sig, T, int, type)
            if (nargin == 4)
                type = obj.TYPES.undef;
            end
            [~, i_start ] = min(abs(T - int(1)));
            [~, i_end ] = min(abs(T - int(2)));
            obj.addPart(sig(i_start:i_end), T(i_start:i_end), type);
        end
        
        function ints = getAsIntervals(obj)
            ints = zeros(length(obj.layers), 2);
            for i = 1:length(obj.layers)
                ints(i, :) = obj.layers(i).int;
            end
        end
        
        function mask = getAsMask(obj, T)
            mask = zeros(size(T));
            for i = 1:length(obj.layers)
                mask = mask | (T >= obj.layers(i).int(1) & T < obj.layers(i).int(2));
            end
        end
        
        function objs = getAsObjects(obj)
            objs = obj.layers;
        end
    end
end