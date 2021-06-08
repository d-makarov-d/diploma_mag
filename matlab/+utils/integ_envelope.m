function [x_e, e] = integ_envelope(T, sig)
% Forms an envelope function, by passing an integating frame through
% signal modulus.
% T - time series
% sig - signal
% x_e - time series for envelope
% e - envelope

    [x_e, e] = integ_frame_fft(T, abs(sig), 2000);
    
    function [x, a] = integ_frame_fft(X, Y, fr_len)
        if rem(fr_len, 2) ~= 0
            fr_len = fr_len + 1;
        end
        half_len = floor((fr_len)./2);
        x = X(half_len:(length(X)-half_len));
        step = zeros(size(Y));
        step(1:fr_len) = 1;
        y = ifft( fft(Y) .* fft(step) ) / 2000 * 62.5;
        a = y(fr_len:length(X));
    end
end