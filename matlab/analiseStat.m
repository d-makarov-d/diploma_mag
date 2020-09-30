function analiseStat()
    DATA_LEN = 24000; % preset length of a sample signal
    FS = 62.5;
    
    % load classified data, which was made by another script
    load('patterns\classified.mat');
    
    % sort intervals by their type and write them to sets
    sets = cell.empty(max(cell2mat({intervals.type})), 0);
    
    for i = 1:length(intervals)
        type = intervals(i).type;
        s = struct('data', intervals(i).data, ...
                'time', intervals(i).time - intervals(i).interval(1), ...
                'interval', intervals(i).interval);
        if (isempty(sets))
            sets{type,1} = s;
        else
            sets{type}(end+1) = s;
        end
    end
    
    
end

% draw data batc for each set
function drawSets(sets)
    for i=1:length(sets)
        figure();
        hold on;
        for j = 1:length(sets{i})
            plot(sets{i}(j).time, sets{i}(j).data);
        end
        hold off
    end
end