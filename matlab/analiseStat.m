function sets = analiseStat()
    global ALL_FLIPS_SAMPLES;
    
    DATA_LEN = 24000; % preset length of a sample signal
    FS = 62.5;
    ALL_FLIPS_SAMPLES = 8;
    
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
        stdS = struct('data', intervals(i).data, ...
                'time', intervals(i).time - intervals(i).interval(1), ...
                'interval', intervals(i).interval);
            
        sets{type}(end+1) = stdS;
    end
    
    % normalize all data
    sets = mNormalize(sets);
    
    findSetAverage({sets{2}.data});
end

function findSetAverage(samples)
    global ALL_FLIPS_SAMPLES;
    % I step of correlating sets
    % because sets can be flipped, we take ALL_FLIPS_SAMPLES random samples, 
    % and calculate all 2^ALL_FLIPS_SAMPLES available combinations of flips
    figure('Name', 'Input Data');
    drawSet(samples);
    
    % to be in array bounds
    samples = samples(1:min([length(samples), ALL_FLIPS_SAMPLES]));
    allFlips = mkAllFlips(samples);
    
    % calculate averege and std for all sample combinations
    % and select result with minimum std area
    bestAvg = [];
    bestStd = [];
    bestI = 0;
    stdS = Inf;
    for i = 1:length(allFlips)
        [avg, dev] = avgByCorr(allFlips{i}); 
        stdSNew = trapz(dev);
        if (stdSNew < stdS) 
            stdS = stdSNew;
            bestAvg = avg;
            bestStd = dev;
            bestI = i;
        end
    end
    data(1:length(samples)) = allFlips{bestI};
    
    if (length(data) <= ALL_FLIPS_SAMPLES)
        % if there is no more data, just return best averege
    else
        % else stage 2
        % flip all the res of data according to correlation with
        % bestAvg, and find the resulting average
        
        for i = (ALL_FLIPS_SAMPLES+1):length(data)
            straight = data{i};
            flipped = flip(data{i});
            crrS = max(xcorr(bestAvg, straight));
            crrF = max(xcorr(bestAvg, flipped));
            
            if (crrF > crrS)
                data{i} = flipped;
            end
        end
    end
    figure('Name', 'Flipped Data');
    drawSet(data);
    
    % calculate averege, using properly flipped set
    [avg, dev, shifted] = avgByCorr(data);
    figure('Name', 'result');
    drawAvgDev(avg, dev, shifted);
end

% find averege signals by maximum correlation
function [avg, dev, shifted] = avgByCorr(sig)
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

function drawSet(set)
    hold on;
    for i = 1:length(set)
        plot(set{i});
    end
    hold off
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

% draw average signal and stndart deviation fom it
function drawAvgDev(avg, dev, shifted)
    sDev = trapz(dev);
    hold on;
    pDev = fill([1:length(avg), length(avg):-1:1], [avg + dev/2, flip(avg - dev/2)], ...
        'r', 'FaceAlpha', 0.7, 'LineStyle', 'none');
    pa = plot(avg, 'k', 'LineWidth', 2);
    pd = plot(shifted', 'g');
    legend([pd(1), pa, pDev], {'Data', 'Averege', sprintf('Standert Deviation;\nArea = %.2f', sDev)});
    set(gcf, 'Color', 'w');
    hold off;
end

function all = mkAllFlips(set)
    function all = recFun(set, ind)
        if (ind <= length(set))
            set2 = set;
            set2{ind} = flip(set{ind});
            all = [recFun(set, ind+1), recFun(set2, ind+1)];
        else
            all = {set};
        end
    end
    all = recFun(set, 1);
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