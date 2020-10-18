function [T, sig, FS] = readSignals(path, expr)
% reads signals from specified folder
% if a regular expression is specified, reads signals only mathing this
% expression
    if (nargin == 1)
        expr = '.+\.adb'; % default expression, describing all *.adb files
    end
    
    % content of the passed directory
    files = dir(path);
    % names of parsed files with data
    names = cell.empty;
    for i = 1:length(files)
        if (~files(i).isdir)
            match = regexp(files(i).name, expr, 'match');
            if (~isempty(match))
                names{end+1} = [files(i).folder '\' files(i).name];
            end
        end
    end
    
    if isempty(names)
        warning('No .adb files found');
        return;
    end
    
    data = cell(1, length(names));
    fs = zeros(1,length(names));
    stn = zeros(1,length(names));
    for i = 1:length(names)
        %file reading in mkm/sec
        [y,par] = utils.adb_read(names{i},'s',0);
        %time vector, T in seconds
        data{i}.T = (0:length(y)-1)/par.fs;
        %signal
        data{i}.sig = (y(:,2)-mean(y(:,2)))';
        data{i}.start = par.stst;
        fs(i) = par.fs;
        stn(i) = par.stn;
    end
    
    % check, that all sample rates are equal
    if (~isempty(find(fs - fs(1), 1)))
        warning('Different smaple rates detected');
    end
    
    % check, that all signals are frome one station
    if (~isempty(find(stn - stn(1), 1)))
        warning('Signal are from different stations');
    end
    
    FS = fs(1);
    % collect lengthes of recordings
    lens = fold(@(acc, el) [acc length(el.T)], [0, data]);
    lens(1) = [];
    % collect start times of resordings
    starts = fold(@(acc, el) [acc el.start], [0, data]);
    starts(1) = [];
    
    [~, order] = sort(starts);
    
    % allocate needed vriables
    T = zeros(1, sum(lens));
    sig = zeros(1, sum(lens));
    shift = 1;
    T0 = starts(order(1));
    
    for i=1:length(data)
        ind = order(i);
        startSec = (data{ind}.start - T0)*24*60*60;
        T(shift:shift + lens(ind) - 1) = startSec + data{ind}.T;
        sig(shift:shift + lens(ind) - 1) = data{ind}.sig;
        shift = shift + lens(ind);
    end
end