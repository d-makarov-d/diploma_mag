function sets = analiseStat()
    DATA_LEN = 24000; % preset length of a sample signal
    FS = 62.5;
    
    % load classified data, which was made by another script
    load('patterns\classified.mat');
    
    % sort intervals by their type and write them to sets
    % sets is a cell vector, containing stucts with fields:
    % data - vector of the signal values
    % time - time vector
    % interval - time interval of a signal
    % type - for signal type
    sets = cell(1, max(cell2mat({intervals.type})));
    
    for i = 1:length(intervals)
        type = intervals(i).type;
        s = struct('data', intervals(i).data, ...
                'time', intervals(i).time - intervals(i).interval(1), ...
                'interval', intervals(i).interval);
            
        sets{type}(end+1) = s;
    end
    
    % normalize all data
    sets = mNormalize(sets);
    
    avgByCorr({sets{1}.data}); 
end

% find averege signals by maximum correlation
function avgByCorr(sig)
    % matrix, containing shifts for each signal to maximaly correlate with
    % every other signal
    toMax = zeros(length(sig));
    % correlations, jbtained by every shift
    corrMax = zeros(length(sig));
    for i = 1:length(sig)
        for j = 1:length(sig)
            [crr, lags] = xcorr(sig{j}, sig{i});
            [mCrr, Icrr] = max(crr);
            toMax(j,i) = lags(Icrr);
            corrMax(j,i) = mCrr;
        end
    end
    
    % put data in such rows, that will fit them all in respect to shifts
    % applying first row (align by first data)
    rightBound = 0;
%     mainRow = 9;
%     shift = toMax(mainRow,:);
    corrMax = corrMax / max(corrMax(:));    %normalize corrMax to 1
    corrMax = corrMax ./ sum(corrMax, 2);   % make sum of each row be 1
    shift = round(sum(-toMax .* corrMax, 2)');
    for i=1:length(sig)
        if (length(sig{i}) + shift(i) > rightBound)
            rightBound = length(sig{i}) + shift(i);
        end
    end
    len = rightBound - min(shift);
    startPos = - min(shift) + 1;
    
    shifted = NaN(length(sig), len);
    for i=1:length(sig)
        i0 = startPos + shift(i);
        i1 = i0 + length(sig{i}) - 1;
        shifted(i, i0:i1) = sig{i};
    end
    
    % compute averege and standard devialtion of centered signals
    avg = mean(shifted, 1, 'omitnan');      % mean for every column, ommiting NaN
    dev = std(shifted, 0, 1, 'omitnan');    % standart deviation for each column, ommiting NaN
    sDev = trapz(dev);
    
    hold on;
    pDev = fill([1:length(avg), length(avg):-1:1], [avg + dev/2, flip(avg - dev/2)], ...
        'r', 'FaceAlpha', 0.7, 'LineStyle', 'none');
    pd = plot(shifted', 'g');
%     ps = plot(shifted(mainRow,:), 'b', 'LineWidth', 1);
    pa = plot(avg, 'k', 'LineWidth', 1);
    legend([pd(1), pa, pDev], {'Data', 'Averege', sprintf('Standert Deviation;\nArea = %.2f', sDev)});
    set(gcf, 'Color', 'w');
    hold off;
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

% make signals min value be at zero, and normalize signals to [0 1]
function sets = mNormalize(sets)
    for t=1:length(sets)
        for i = 1:length(sets{t})
            lowest = min(sets{t}(i).data);
            highest = max(sets{t}(i).data);
            sets{t}(i).data = (sets{t}(i).data - lowest) / (highest - lowest); 
        end
    end
end

% compute correlation between two signals
% for all superpositions of those dignals
% function moveCorr(X, Y)
%     lX = length(X);
%     lY = length(Y);
%     len = 2*(lY - 1) + lX;
%     lag = (-lY + 1):(lX-1);
%     x = zeros(1, len);
%     y = zeros(length(lag), len);
%     c = zeros(1, length(lag));
%     c1 = zeros(1, length(lag));
%     
%     x(lY:lY-1+lX) = X;
%     for i=1:length(lag)
%         y(i,i:i-1+lY) = Y;
%         c(i) = corr(x', y(i,:)', 'Type', 'Pearson');
%     end
% end