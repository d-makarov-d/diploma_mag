% function, parsing folder, recursively if specified, and returning names
% of matched .adb files
function names = parseFolder(path, r, expr)
    import utils.parseFolder
    % content of the parsed directory
    files = dir(path);
    names = cell.empty;
    for i = 1:length(files)
        if (~files(i).isdir)
            match = regexp([path '\' files(i).name], expr, 'match');
            if (~isempty(match))
                names{end+1, 1} = [files(i).folder '\' files(i).name];
                names{end, 2} = files(i).name;
            end
        elseif (r && ~strcmp(files(i).name, '.') && ~strcmp(files(i).name, '..'))
            names = [names; parseFolder([path '\' files(i).name], r, expr)];
        end
    end
end