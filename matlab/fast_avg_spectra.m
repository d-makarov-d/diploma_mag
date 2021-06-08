function fast_avg_spectra(T, sig, model)
    tic
    filtered = model.applyAdjusted(sig);
    [x_env, env] = utils.integ_envelope(T, filtered);
    env = env ./ max(env);
    
    [~,x_pk,w_pk,~,wx_pk] = utils.m_findpeaks(env, x_env, 'MinPeakProminence', 0.15, 'WidthReference', 'halfheight');
    t = toc;
    fprintf('%d intervals detected in %.2f sec\n', length(x_pk), t);
end