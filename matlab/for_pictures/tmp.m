function tmp(spect)
    fs = 62.5;
    % spect = spect ./ max(spect);
    y = spect(1: length(spect)/2 + 1);
    x = linspace(0, fs/2, length(y));
    plot(x, y, 'LineWidth', 2);
    set(gca, 'FontSize', 20);
    set(gcf, 'Color', 'w');
    xlabel('Frequency, Hz');
end