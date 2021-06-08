% averages envelopes, saved in patterns\cuttted.mat

clear;
structs = load('patterns\cuttted.mat').ans;

for_avg = to_avg(structs);
t1 = for_avg(1);
t1(1) = [];
t2 = for_avg(1);
t2(1) = [];
for i = 1:length(for_avg)
    if (for_avg(i).type == 1)
        t1(end + 1) = for_avg(i);
    elseif (for_avg(i).type == 2)
        t2(end + 1) = for_avg(i);
    end
end

analiseStat(for_avg);
lens = half_width_t_averagin(for_avg);
lens1 = half_width_t_averagin(t1);
lens2 = half_width_t_averagin(t2);

function for_avg = to_avg(structs)
    v0 = cell(1, length(structs));
    for_avg = struct('data', v0, 'time', v0, 'type', v0, 'interval', v0);
    for i = 1:length(structs)
        if (~strcmp(structs(i).type, utils.Intervals.TYPES.undef))
            for_avg(i).data = structs(i).env;
            for_avg(i).time = structs(i).T - structs(i).T(1);
            if (structs(i).type == utils.Intervals.TYPES.t1)
                for_avg(i).type = 1;
            elseif (structs(i).type == utils.Intervals.TYPES.t2)
                for_avg(i).type = 2;
            end
            for_avg(i).interval = structs(i).int;
        end
    end
end