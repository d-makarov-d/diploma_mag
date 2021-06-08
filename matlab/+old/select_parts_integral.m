%22890216.adb - не шум
%22880207.adb - шум

function select_parts_integral()
    global sig T fun FRAME_LENGTH dX sig_axes region intervals sig_mouse_btn_pressed add_btn;
    %file reading in mkm/sec
    [y,par]=adb_read('22890216.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    %signal
    [sig, T, fun] = filter_sig(T, y(:,2)-mean(y(:,2)));
    
    dX = 0;
    sig_mouse_btn_pressed = 0;
    FRAME_LENGTH = 800;
    intervals = struct.empty;
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
            dX = dX + 10;
        case 'leftarrow'
            dX = dX - 10;
        case 's'
            
        case {'1', '2', '3'}
            add_region(str2double(event.Key));
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
        f1 = T > intervals(i).interval(1);
        f2 = T < intervals(i).interval(2);
        f = (f1+f2) == 2;
        fram_regs = fram_regs + f;       
    end
    fram_regs = fram_regs + fram;
    fram_regs = fram_regs >= 2;
end

function replot()
    global T sig_axes dX sig fun region add_btn;
    hold off;
    [fram, fram_regs] = frame(dX);
    plot(sig_axes, T(fram), sig(fram) ,'b');
    hold on;
    plot(sig_axes, T(fram), fun(fram) ,'m');
    plot(sig_axes, T(fram), 50*ones(1,length(T(fram))) ,'m');
    plot(sig_axes, T(fram_regs), sig(fram_regs) ,'r');
    hold off;
    axis(sig_axes, 'tight');
    sig_axes.YLim = [-50 200];
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

function add_region(type)
    global fun T region intervals;
    if ~isempty(region)
        ind = length(intervals)+1;
        intervals(ind).data = fun( get_time_point(region.Position(1) ):get_time_point( region.Position(1) + region.Position(3) ));
        intervals(ind).time = T( get_time_point(region.Position(1) ):get_time_point( region.Position(1) + region.Position(3) ));
        intervals(ind).type = type;
        intervals(ind).interval = [region.Position(1), region.Position(1) + region.Position(3)];
    end
    replot();
end

function [a, x, y] = integ_frame(X, Y, fr_len)
    if rem(fr_len, 2) == 0
        fr_len = fr_len + 1;
    end
    half_len = (fr_len - 1)./2;
    x = X(half_len:(length(X)-half_len));
    y = Y(half_len:(length(Y)-half_len));
    Y = abs(Y);
    a = zeros(size(x));
    for i = 1:(length(x)-1)
        interval = half_len + ((i - half_len) : (i + half_len));
        a(i) = trapz(X(interval), Y(interval));
    end
end

function an = mul(a, b)
    frame = fix(length(a)/length(b));
    an = zeros(size(a));
    for i = 0:(length(b)-1)
        an((i*frame+1):(i+1)*frame) = a((i*frame+1):(i+1)*frame) .* b(i+1);
    end
    an(((length(b))*frame):length(a)) = a(((length(b))*frame):length(a)) .* b(length(b));
end

function [sig_out, T, fun] = filter_sig(T, sig_0)
    str = fileread('ans_sig_part_2.dta');
    var = str2double(strsplit(str, '|'));
    var(length(var)) = [];
    var = (var - min(var))./(max(var) - min(var));
    
    fft_sig = fft(sig_0);
    fft_sig1 = mul(fft_sig,var);
    sig = real(ifft(fft_sig1));
    
    [fun, T, sig_out] = integ_frame(T, sig, 2001);
end

function x = get_time_point(X)
    global T;
    [~,x] = min(abs(T - X));
end
