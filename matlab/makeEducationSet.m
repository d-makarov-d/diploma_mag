function makeEducationSet(path, r, expr)
% path - path to folder
% r - parse subfolders if true
% expr - match regexp
% makes set for educating a filter from files, found in specified
% folder (path), and mathing the regular expression (expr), if provided
    switch nargin
        case 1
            [T, sig, FS] = utils.readSignals(path);
        case 2
            [T, sig, FS] = utils.readSignals(path, r);
        otherwise
            [T, sig, FS] = utils.readSignals(path, r, expr);
    end
    
    % get frame duration in seconds
    FRAME_T = 25;
    inp = input(sprintf('Enter education sample length (sec) [default %.2f s]: ', FRAME_T), 's');
    while ~(validValueInput(inp) || isempty(inp))
        disp('input maust be a valid double');
        inp = input(sprintf('Enter education sample length (sec) [default %.2f s]: ', FRAME_T), 's');
    end
    if ~isempty(inp)
        FRAME_T = str2double(inp);
    end
    disp(FRAME_T);
    DX = 0;                         % frame shift
    OUTER_FRAME_T = 500;            % frame for displaying signal
    examples = {};                  % container for training examples
    nTrain = 0;                     % quantity of signals with train
    nNoTrain = 0;                     % quantity of signals without train
    
    % frames for signal and fourier display
    sc_sz = get(0,'ScreenSize');
    screenW = sc_sz(3);
    screenH = sc_sz(4);
    fig = figure('Name', 'Sample Selection', ...
        'NumberTitle', 'off', ...
        'Position', [10, 50, screenW-20, screenH - 130]);
    sig_axes = axes(fig, 'Position', [0.06, 0.07, 0.78, 0.41]);
    fourier_axes = axes(fig, 'Position', [0.06, 0.55, 0.78, 0.41]);
    log_box = uicontrol(fig, ...
        'Style', 'listbox', ...
        'Units', 'normalized', ...
        'Position', [0.86, 0.04, 0.13, 0.92], ...
        'BackgroundColor', 'white');
    
    % set callback for key controls
    fig.WindowKeyPressFcn = @onKeyPressed;
    
    % initial plot of signal and frame
    plot(sig_axes, T, sig );
    rect = rectangle(sig_axes, ...
        'Position', [ DX, sig_axes.YLim(1), FRAME_T, sig_axes.YLim(2)-sig_axes.YLim(1)], ...
        'FaceColor', [0,1,0,0.2] );
    replot();
    
    % show signal, fourier and the prame on axes
    function replot()
        sig_axes.YLim = [-65 65];
        rect.Position = [ DX, sig_axes.YLim(1), FRAME_T, sig_axes.YLim(2)-sig_axes.YLim(1)];
        sig_axes.XLim = [DX - floor(OUTER_FRAME_T/2), DX + ceil(OUTER_FRAME_T/2)];

        fourier = fft( sig(frame) );
        plot(fourier_axes, ...
            linspace(0, FS/2, floor(length(fourier)/2) + 1), ...
            abs( fourier( 1:floor(length(fourier)/2) + 1) ), ...
            'LineWidth', 1);
        fourier_axes.YLim = [0 10000];

        xlabel(sig_axes, 'Time (sec)');
        ylabel(sig_axes, 'Acceleration (mkm/sec)');

        xlabel(fourier_axes, 'Frequancy (Hz)');
        ylabel(fourier_axes, 'Spectral power');
    end

    % make mask, according to frame length and DX
    function fram = frame()
        fram1 = T > DX;
        fram2 = T < DX + FRAME_T;
        fram = (fram1 + fram2) == 2;
    end

    % keyboard controls
    function onKeyPressed(~, event)
        switch event.Key
            case 'rightarrow'
                DX = DX + 3;
            case 'leftarrow'
                DX = DX - 3;
            case '1'
                examples{end+1} = {sig(frame), 1}; %signal
                nTrain = nTrain + 1;
                log(sprintf('train: %d (added), no train: %d)', nTrain, nNoTrain));
            case '0'
                examples{end+1} = {sig(frame), 0}; %no signal
                nNoTrain = nNoTrain + 1;
                log(sprintf('train: %d, no train: %d (added)', nTrain, nNoTrain));
%             case 's'
%                 save('patterns/sig2_part_2_pattern.mat', 'pattern');
%                 fileID = fopen('patterns/train2_part_2.csv', 'w');
%                 format_spec = '%f';
%                 for i = 1:(DOT_LENGTH-1)
%                     format_spec = strcat(format_spec, ' %f');
%                 end
%                 format_spec = strcat(format_spec, ' %i\n');
%                 fprintf(fileID, '%i %i\n', [DOT_LENGTH, length(pattern)]);
%                 for i = 1:length(pattern)
%                     fprintf(fileID, format_spec, pattern{i});
%                 end
%                 fclose(fileID);
        end
        replot();
    end

    function log(str)
        log_box.String{end+1} = str;
        log_box.Value = length(log_box.String);
    end
end

function valid = validValueInput(str)
    match = regexp(str, '^-?\d+\.?\d*$', 'match');
    valid = ~isempty(match);
end