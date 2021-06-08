% script for sorting envelopes by types
clear;
% loda models for classification
load('C:\Users\Danil_win\Documents\FF\diploma_mag\matlab\patterns\averaged.mat');

[T, sig] = utils.readSignals('seismic_data/covid_time/AZT-20201024T083856Z-001/AZT/AZT_AZT_200317_2289000');
% [T, sig, ~, T0] = utils.readSignals('seismic_data/AZT_190506', false, '.+[0-4].\.adb');
% [T, sig, ~, T0] = utils.readSignals('seismic_data/covid_time/AZT-20201024T083856Z-001/AZT', true ,'.+AZT_AZT_200317_228900[0-9].+\.adb');
sig = utils.anti_eject(sig, T);

filter = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');

[ints] = utils.detect_signals(T, sig, filter);

intervals = ints.getAsObjects();

for i = 1:length(intervals)
    int = intervals(i);
    noremed = int.env - min(int.env);
    noremed = noremed ./ max(noremed);
    
    same_len = mk_same_langth({noremed, type1.avg, type2.avg});
    same_len_f = mk_same_langth({noremed, flip(type1.avg), flip(type2.avg)});
    [envXt1, lagT1] = xcorr(same_len{1}, same_len{2}, 'normalized');
    env_f = xcorr(same_len{1}, same_len_f{2}, 'normalized');
    if(max(env_f) > max(envXt1))
        [envXt1, lagT1] = xcorr(same_len{1}, same_len_f{2}, 'normalized');
        same_len{2} = same_len_f{2};
    end
    [envXt2, lagT2] = xcorr(same_len{1}, same_len{3}, 'normalized');
    env_f = xcorr(same_len{1}, same_len_f{3}, 'normalized');
    if(max(env_f) > max(envXt2))
        [envXt2, lagT2] = xcorr(same_len{1}, same_len_f{3}, 'normalized');
        same_len{3} = same_len_f{3};
    end
    
    [~, i_t1] = max(envXt1);
    [~, i_t2] = max(envXt2);
    
    lag_t1 = lagT1(i_t1);
    lag_t2 = lagT1(i_t2);
    
    t1 = ((1:length(same_len{1})) + lag_t1) / 62.5;
    t2 = ((1:length(same_len{1})) + lag_t2) / 62.5;
    
    hold on
    cla;
    plot(int.T, noremed, 'r')
    plot(t1, same_len{2}, 'g')
    plot(t2, same_len{3}, 'b')
    title(sprintf('[%d/%d] type1: %.3f, type2: %.3f', i, length(intervals), max(envXt1), max(envXt2)))
    hold off;
    
    waitforbuttonpress
    % key from keybord 49 == "1", 50 == "2", 51 == "3"
    value = double(get(gcf,'CurrentCharacter'));
    
    switch value
        case 49
            intervals(i).type = utils.Intervals.TYPES.t1;
        case 50
            intervals(i).type = utils.Intervals.TYPES.t2;
        otherwise
            intervals(i).type = utils.Intervals.TYPES.undef;
    end
end
% filtered = filter.applyAdjusted(sig);
% [x_env, env] = utils.integ_envelope(T, filtered);
% env = env ./ max(env);
% 
% utils.info_plot({[x_env; env]}, {big_ints, small_ints});

function res = mk_same_langth(series)
    max_l = max(arrayfun(@(x) length(x{1}), series));
    res = arrayfun(@(x) [x{1}, zeros(1, max_l - length(x{1}))], series, 'UniformOutput', false);
end

