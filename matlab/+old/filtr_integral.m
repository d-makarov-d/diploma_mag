function [mask, x_a, a] = filtr_integral(T, sig, filter, treshold)
    
    sig1 = filter.applyAdjusted(sig);
    [mask, x_a, a] = apply_frame(T,sig1, 2000);
    hold on;
    plot(T,sig1, 'b');
    plot(T(mask), sig1(mask), 'r');
    plot(T,sig - 50, 'b');
    plot(x_a, a * 75 + 20, 'g');
    plot([T(1), T(end)], [treshold treshold]  * 75 + 20, 'k');
    %plot(T(mask),sig(mask) - 25, 'r');
    %ylim([-60, 100]);
    
    function [x,a] = integ_frame_fft(X, Y, fr_len)
        if rem(fr_len, 2) ~= 0
            fr_len = fr_len + 1;
        end
        half_len = floor((fr_len)./2);
        x = X(half_len:(length(X)-half_len));
        step = zeros(size(Y));
        step(1:fr_len) = 1;
        y = ifft( fft(Y) .* fft(step) );
        a = y(fr_len:length(X));
    end

    function [ans_mask, x_a, y] = apply_frame(X,Y, fr_len)
        [x_a, y] = integ_frame_fft(X, abs(Y), fr_len);
        y = y./max(y);
        if rem(fr_len, 2) ~= 0
            fr_len = fr_len + 1;
        end
        half_len = floor((fr_len)./2);
    %     s2 = Y(half_len:length(X)-half_len);
    %     x = X(half_len:length(X)-half_len);
        %y2 = conv(ones(1,1000), abs(sig1));
        mask0 = y > treshold;
        ans_mask = false(size(X));
        ans_mask(half_len:length(X)-half_len) = mask0;
    end
end