function cut = test_cut_intervals(uncut)
% Cut intervals of signal
    sig_mouse_btn_pressed = 0;
    region = rectangle( ...
            'Position', [ 0, gca().YLim(1), 1, gca().YLim(2)-gca().YLim(1)], ...
            'FaceColor', [0,1,0,0.2] ...
            );

    cut = uncut(1);
    cut(1) = [];
    for i = 1:length(uncut)
        if (~strcmp(uncut(i).type, utils.Intervals.TYPES.undef))
            cut(end + 1) = uncut(i);
        end
    end
    for i = 1:length(cut)
        plot(cut(i).T, cut(i).env);
        title(sprintf('[%d/%d] type: %s', i, length(cut), cut(i).type));
        region = rectangle( ...
            'Position', [ 0, gca().YLim(1), 0, gca().YLim(2)-gca().YLim(1)], ...
            'FaceColor', [0,1,0,0.2] ...
            );
        
        sig_fig = gcf;
        sig_fig.WindowButtonDownFcn = @mouse_btn_down;
        sig_fig.WindowButtonUpFcn = @mouse_btn_up;
        sig_fig.WindowButtonMotionFcn = @mouse_btn_motion;
        
        w = 0;
        while w == 0
            w = waitforbuttonpress;
        end
        % key from keybord 13 == "enter"
        value = double(get(gcf,'CurrentCharacter'));
        if (value == 13)
            new_int = [region.Position(1) region.Position(1) + region.Position(3)];
            [~, i_b]= min(abs(cut(i).T - new_int(1)));
            [~, i_e]= min(abs(cut(i).T - new_int(2)));
            cut(i).sig = cut(i).sig(i_b:i_e);
            cut(i).T = cut(i).T(i_b:i_e);
            cut(i).int = cut(i).int(1) + [cut(i).T(1) cut(i).T(end)];
            cut(i).env = cut(i).env(i_b:i_e);
        end
        close(sig_fig)
    end
    
    
    function mouse_btn_down(source, event)
        sig_axes = gca;
        x = sig_axes.CurrentPoint(1,1);
        y = sig_axes.CurrentPoint(1,2);
        sig_mouse_btn_pressed = 1;
        hold on
        region.Position = [ x, sig_axes.YLim(1), 1, sig_axes.YLim(2)-sig_axes.YLim(1)];
    end

    function mouse_btn_up(source, event)
        
        sig_mouse_btn_pressed = 0;
    end

    function mouse_btn_motion(source, event)
        sig_axes = gca;
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
end