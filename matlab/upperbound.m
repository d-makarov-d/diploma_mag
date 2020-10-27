function [S, T] = upperbound(path, frameLen)
% path - path to folder to parse
% frameLen - length of frame, in which the signal will be devided
% process big signals, segnificantly lowering their sample rate, and
% returning highest points in frames of specified legth
    if (nargin == 1)
        frameLen = 1500;
    end
    % recursively parse all .adb files in folder
    names = utils.parseFolder(path, true, '.+\.adb');
    % using Java linked lists to quickly add doubles to unknown - size list
    Slist = java.util.LinkedList;
    Tlist = java.util.LinkedList;
    
    % the files must be processed one - by one, not to run out of memory
    for i=1:size(names, 1)
        [t, sig, ~, t0] = utils.readSignals(names{i});
        % find maximal values in frames, then store them to output sequence
        nFrames = floor(length(t) / frameLen);
        for f = 1:nFrames
            [m, mI] = max(sig((f-1)*frameLen+1 : (f)*frameLen));
            Slist.listIterator.add(m);
            Tlist.listIterator.add(t0 + t((f-1)*frameLen + mI));
        end
        [m, mI] = max(sig(nFrames*frameLen : end));
        Slist.listIterator.add(m);
        Tlist.listIterator.add(t0 + t(nFrames*frameLen - 1 + mI));
    end
    % output sequence of maximal signal values
    S = zeros(1, Slist.size); 
    T = zeros(1, Tlist.size);
    for i = 1:Slist.size
        S(i) = Slist.pop;
        T(i) = Tlist.pop;
    end
end