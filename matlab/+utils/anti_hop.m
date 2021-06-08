function data = anti_hop(data)
    dif = diff(data);
    ind = find(abs(dif) > 2*std(dif));
    for i = 1:length(ind)
        delta = data(ind(i) + 1) - data(ind(i));
        data(ind(i) + 1 : end) = data(ind(i) + 1 : end) - delta;
    end
end