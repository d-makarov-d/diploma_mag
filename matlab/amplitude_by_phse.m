function ampl = amplitude_by_phse(int)
% Calculates peak-to-peak ampltude
% int - part of a signal
    sig = int.sig;
    [~, top_i] = max(sig);
    m = islocalmin(sig, 'MinProminence', 2 * std(sig));
    m_is = find(m);
    m_i = m_is(m_is > top_i);
    if (length(m_i) < 1) 
        ampl = nan;
    else
        m_i = m_i(1);
        ampl = max(sig(top_i:m_i)) - min(sig(top_i:m_i));
    end
end