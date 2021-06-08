function lens = half_width_t_averagin(intervals)
% calculates duration of peak< higher than it's half widts
    lens = double.empty(0, length(intervals));
    for i = 1:length(intervals)
        lens(i) = hw_length(intervals(i).data, intervals(i).time);
    end
end

function len = hw_length(sig, T)
    normed = (sig - min(sig)) ./ max(sig - min(sig));
    % multiplication of every nearby element
    high_low = (normed - 0.5) .* circshift(normed - 0.5, 1);
    high_low(1) = 1;
    mask = high_low < 0;
    inds = find(mask);
    points_b.x1 = T(inds(1) - 1);
    points_b.y1 = normed(inds(1) - 1);
    points_b.x2 = T(inds(1));
    points_b.y2 = normed(inds(1));
    points_e.x1 = T(inds(end) - 1);
    points_e.y1 = normed(inds(end) - 1);
    points_e.x2 = T(inds(end));
    points_e.y2 = normed(inds(end));
    
    t_b = interp1([points_b.y1, points_b.y2], [points_b.x1, points_b.x2], 0.5);
    t_e = interp1([points_e.y1, points_e.y2], [points_e.x1, points_e.x2], 0.5);
    len = t_e - t_b;
    
%     hold on;
%     plot(T, normed);
%     plot([0, max(T)], [0.5, 0.5]);
%     plot(T(mask), normed(mask), 'or');
%     plot(T(circshift(mask, -1)), normed(circshift(mask, -1)), 'og');
%     plot([t_b, t_e], [0.5, 0.5], '*c');
end