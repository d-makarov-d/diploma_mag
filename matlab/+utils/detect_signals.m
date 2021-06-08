function [intervals] = detect_signals(T, sig, model)
% Finds train signals on signal
% T - time series
% sig - signal
% model - trained model for filtering
% intervals - Intervals, for detected signals
    filtered = model.applyAdjusted(sig);
    [x_env, env] = utils.integ_envelope(T, filtered);
    env = env ./ max(env);
    
    % find peaks higher than 0.2
    % x_pk - locations of peaks
    % w_pk - half-width of the peak
    % wx_pk - location of center of peak width
    tic
    [~,x_pk,w_pk,~,wx_pk] = utils.m_findpeaks(env, x_env, 'MinPeakProminence', 0.15, 'WidthReference', 'halfheight');
    t = toc;
    % fprintf('%d intervals detected in %.2f sec\n', length(x_pk), t);
    % utils.info_plot({[T; sig], [T; abs(filtered)], [x_env; env]}, {});
    tic
    intervals = utils.Intervals();
    for i = 1:length(x_pk)
        int = [0 w_pk(i)] + wx_pk(i);
        int(1) = int(1) - 0.1 * (int(2) - int(1));
        int(2) = int(2) + 0.1 * (int(2) - int(1));
        mask = T > int(1) & T < int(2);
        mask_e = x_env > int(1) & x_env < int(2);
        intervals.addPart(sig(mask), env(mask_e), T(mask));
    end
    t = toc;
    % fprintf('intervals formed in %.2f sec\n', t);
    
    % utils.info_plot({[T; sig], [T; abs(filtered)], [x_env; env]}, {intervals.getAsIntervals()});
end