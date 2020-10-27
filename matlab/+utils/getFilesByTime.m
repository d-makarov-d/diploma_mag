% interval - interval of time
% returns names of files, data in which occures inside the interval
function matched = getFilesByTime(path, interval)
    T0 = interval(1);
    T1 = interval(2);
    matched = {};
    
    % recursively parse all .adb files in folder
    names = utils.parseFolder(path, true, '.+\.adb');
    
    % process all found files, sving needed names
    for i=1:size(names, 1)
        [t, ~, ~, t0] = utils.readSignals(names{i});
        if inside(t0 + t(end)) || inside(t0)
            matched{end + 1} = names{i};
        end
    end
    
    function in = inside(t)
        in = (t >= T0) && (t <= T1);
    end
end