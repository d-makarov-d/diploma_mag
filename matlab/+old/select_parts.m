%22890216.adb - не шум
%22880207.adb - шум

function select_parts()
    global sig T FRAME_LENGTH dX sig_axes region intervals sig_mouse_btn_pressed add_btn;
    %file reading in mkm/sec
    [y,par]=adb_read('22890216.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    %fft signal
    sig = y(:,2)-mean(y(:,2));
    
    dX = 0;
    sig_mouse_btn_pressed = 0;
    FRAME_LENGTH = 400;
    intervals = cell.empty;
    region = matlab.graphics.primitive.Rectangle.empty;
    
    %figure
    sig_fig = figure('Name','Signal','NumberTitle','off', 'InnerPosition', [10,100,1500,400]);
    sig_axes = axes(sig_fig, 'Position',[0.05 0.2 0.9 0.7]);
    sig_fig.WindowKeyPressFcn = @key_pressed_callback;
    sig_fig.WindowButtonDownFcn = @mouse_btn_down;
    sig_fig.WindowButtonUpFcn = @mouse_btn_up;
    sig_fig.WindowButtonMotionFcn = @mouse_btn_motion;
    add_btn = uicontrol(sig_fig, ...
        'String', 'Add', ...
        'Style', 'pushbutton', ...
        'Position', [20 20 50 20], ...
        'Callback', @add_callback);
    
    replot();
end

function i = get_dot_length()
    global DELTA_FRAME T;
    i = 1;
    while T(i) < DELTA_FRAME
        i = i + 1;
    end
end

function key_pressed_callback(~, event)
    global dX intervals;
    switch event.Key
        case 'rightarrow'
            dX = dX + 2;
        case 'leftarrow'
            dX = dX - 2;
        case 's'
            save('data1', 'intervals');
        case 'a'
            add_region();
    end
    replot();
end

function [fram, fram_regs] = frame(dx)
    global FRAME_LENGTH T intervals;
    fram1 = T > dx;
    fram2 = T < FRAME_LENGTH + dx;
    fram = (fram1 + fram2) == 2;
    fram_regs = false(size(T));
    for i = 1:length(intervals)
        f1 = T > intervals{i}(1);
        f2 = T < intervals{i}(1) + intervals{i}(2);
        f = (f1+f2) == 2;
        fram_regs = fram_regs + f;       
    end
    fram_regs = fram_regs + fram;
    fram_regs = fram_regs >= 2;
end

function replot()
    global T sig_axes dX sig region add_btn;
    hold off;
    [fram, fram_regs] = frame(dX);
    plot(sig_axes, T(fram), sig(fram) ,'b');
    hold on;
    plot(sig_axes, T(fram_regs), sig(fram_regs) ,'r');
    hold off;
    axis(sig_axes, 'tight');
    sig_axes.YLim = [-200 200];
    region = matlab.graphics.primitive.Rectangle.empty;
    add_btn.Enable = 'off';
end

function mouse_btn_down(source, event)
    global sig_axes sig_mouse_btn_pressed region;
    replot();
    x = sig_axes.CurrentPoint(1,1);
    y = sig_axes.CurrentPoint(1,2);
    sig_mouse_btn_pressed = 1;
    hold on
    region = rectangle('Position', [ x, sig_axes.YLim(1), 1, sig_axes.YLim(2)-sig_axes.YLim(1)], ...
        'FaceColor', [0,1,0,0.2] ...
        );
end

function mouse_btn_up(source, event)
    global sig_mouse_btn_pressed add_btn region;
    sig_mouse_btn_pressed = 0;
    %x = fourier_axes.CurrentPoint(1,1);
    %y = fourier_axes.CurrentPoint(1,2);
    if ~isempty(region)
        add_btn.Enable = 'on';
    end
end

function mouse_btn_motion(source, event)
    global sig_axes sig_mouse_btn_pressed region;
    if sig_mouse_btn_pressed
        x = sig_axes.CurrentPoint(1,1);
        %y = fourier_axes.CurrentPoint(1,2);
        hold on
        if x < region.Position(1)
            region.Position(3) = region.Position(3) + region.Position(1)-x;
            region.Position(1) = x;
        end
        if x > region.Position(1) && x < region.Position(1) + region.Position(3)
            if x - region.Position(1) < region.Position(1) + region.Position(3) - x
                region.Position(3) = region.Position(3) + region.Position(1)-x;
                region.Position(1) = x;
            else
                region.Position(3) = x - region.Position(1);
            end
        end
        if x > region.Position(1) + region.Position(3)
            region.Position(3) = x - region.Position(1);
        end
    end
end

function add_callback(source, event)
    add_region();
end

function add_region()
    global region intervals;
    if ~isempty(region)
        intervals{length(intervals)+1} = [region.Position(1), region.Position(3)];
    end
    replot();
end
