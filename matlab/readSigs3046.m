function [T, sig, FS, T0] = readSigs3046(path, r, expr)
% Same as readSigs, but for other station
% path - path to folder
% r - parse subfolders if true
% expr - match regexp
% decodes binary files, containing signals from specified folder
% if r, parses subfolders
% if a regular expression is specified, reads signals only mathing this
% expression
import utils.parseFolder
    switch nargin
        case 1
            r = false;
            expr = '.+\.adb'; % default expression, describing all *.adb files
        case 2
            expr = '.+\.adb'; % default expression, describing all *.adb files
    end
            
    if (nargin == 1)
        expr = '.+\.adb'; % default expression, describing all *.adb files
    end
    
    % names of parsed files with data
    names = parseFolder(path, r, expr);
    
    if isempty(names)
        warning('No .adb files found');
        T = []; sig = []; FS = 0;
        return;
    end
    
    Nfiles = size(names, 1);
    fprintf('found %i files. ...\n', Nfiles);
    
    data = cell(1, Nfiles);
    fs = zeros(1,Nfiles);
    stn = zeros(1,Nfiles);
    for i = 1:Nfiles
        fprintf('decoding %s ... ', names{i, 2});
        %file reading in mkm/sec
        [y,par] = utils.adb_read(names{i, 1},'s',0);
        %time vector, T in seconds
        data{i}.T = (0:length(y)-1)/par.fs;
        %signal
        data{i}.sig = (y(:,1)-mean(y(:,1)))' * 8;
        data{i}.start = par.stst;
        fs(i) = par.fs;
        stn(i) = par.stn;
        fprintf('success\n');
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