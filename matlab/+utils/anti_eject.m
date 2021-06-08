function corrected = anti_eject(sig, T, dt)
% removes signal intervals with ejections (high pikes etc).
% sig - signal
% T - time series
% dt[optional] - time interval for averaging frame
    if (nargin == 2)
        dt = 4.8;
    end
    
    [~, fr_len] = min(abs(T - (min(T) + dt)));
    stiff = movmean(sig, fr_len);
    treshold = std(stiff) * 7;
    mask = abs(stiff) > treshold;
    corrected = sig;
    corrected(mask) = 0;
end