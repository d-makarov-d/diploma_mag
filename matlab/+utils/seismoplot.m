function seismoplot(x, y, step, n, varargin)
% function, wrapping a mtlab plot function to draw a seismogram
% x, y - data to plot
% n - number of rows
% step - gap between rows
% varargin - arguments for matlab plot
    rowLen = ceil(length(x) / n);
    if ishold
        holdState = 'on';
    else
        holdState = 'off';
    end

    hold on;
    for i=1:n
        lBrdr = (i-1) * rowLen + 1;
        rBrdr = i * rowLen;
        y0 = - step * (i - 1);
        if i>1
            x0 = - x(lBrdr - 1);
        else
            x0 = 0;
        end
        if i < n
            plot(x(lBrdr : rBrdr) + x0, y(lBrdr : rBrdr) + y0, varargin{:});
        else
            plot(x(lBrdr : end) + x0, y(lBrdr : end) + y0, varargin{:});
        end
    end
    hold(holdState);
end