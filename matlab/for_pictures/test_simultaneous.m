clear;
[T_azt, sig_azt, ~, T0_azt] = utils.readSignals('seismic_data/simulataneous/AZT_190506', true);
[T_gaish, sig_gaish, ~, T0_gaish] = readSigs3046('seismic_data/simulataneous/GAISH', true);
sig_azt = utils.anti_eject(sig_azt, T_azt);
sig_gaish = utils.anti_eject(sig_gaish, T_gaish);
sig_gaish(sig_gaish > 7 * std(sig_gaish)) = 0;

[sig_azt, T_azt] = cutInterval(sig_azt, T_azt, T0_azt, '03-May-2019 20:37:50', '03-May-2019 22:19:50');
[sig_gaish, T_gaish] = cutInterval(sig_gaish, T_gaish, T0_gaish, '03-May-2019 20:37:50', '03-May-2019 22:19:50');

filter = utils.loadModel('patterns/models/default_SGD_200eph_0.00100lrate_nornd.model');

[x_env_azt, env_azt] = findEnvelope(T_azt, sig_azt, filter);
[x_env_gaish, env_gaish] = findEnvelope(T_gaish, sig_gaish, filter);

[y_pk_a, x_pk_a] = findpeaks(env_azt, x_env_azt, 'MinPeakProminence', 0.2 * max(env_azt), 'WidthReference', 'halfheight');
[y_pk_g, x_pk_g] = findpeaks(env_gaish, x_env_gaish, 'MinPeakProminence', 0.2 * max(env_gaish), 'WidthReference', 'halfheight');

time_azt = t2time(x_env_azt, T0_azt);
time_gaish = t2time(x_env_gaish, T0_gaish);
hold on
plot(time_azt, env_azt);
plot(time_gaish, env_gaish);
plot(t2time(x_pk_a, T0_azt), y_pk_a, 'or', 'LineWidth', 3);
plot(t2time(x_pk_g, T0_gaish), y_pk_g, 'og', 'LineWidth', 3);
% plot(t2time(T_azt, T0_azt), sig_azt * 10);
% plot(t2time(T_azt, T0_azt), filter.applyAdjusted(sig_azt) * 10);
set(gca, 'FontSize', 20);
set(gcf, 'Color', 'w');
xlabel('Время, сек');
ylabel('Ускорение мкм.с^2');
legend({'AZT огибающая', 'GAISH огибающая', 'Пики AZT', 'Пики GAISH'});

dt = (T0_gaish - T0_azt) * 24 * 60 * 60;
delay = x_pk_a - x_pk_g - dt;
fprintf('average delay: %.2f +- %.2f [sec]\n', mean(delay), std(delay));
fading = y_pk_g ./ y_pk_a;
fprintf('average fading: %.2f +- %.2f\n', mean(fading), std(fading));

fading1 = fading_by_maxima(T_azt, T0_azt, sig_azt, T_gaish, T0_gaish, sig_gaish, filter, false);
fprintf('average fading[1]: %.2f +- %.2f\n', mean(fading1), std(fading1));

% fading2 = fading_by_maxima(T_azt, T0_azt, sig_azt, T_gaish, T0_gaish, sig_gaish, filter, true);
% fprintf('average fading filtered: %.2f +- %.2f\n', mean(fading2), std(fading2));

function [x_env, env] = findEnvelope(T, sig, model)
    filtered = model.applyAdjusted(sig);
    [x_env, env] = utils.integ_envelope(T, filtered);
end

function T = t2time(t, T0)
    T = datetime(t / (24 * 60 * 60) + T0, 'ConvertFrom', 'datenum');
end

function [sigC, tC] = cutInterval(sig, t, t0, b, e)
    time = t2time(t, t0);
    b_t = datetime(b);
    e_t = datetime(e);
    mask = time > b_t & time < e_t;
    sigC = sig(mask);
    tC = t(mask);
end

function fading = fading_by_maxima(T_azt, T0_azt, sig_azt, T_gaish, T0_gaish, sig_gaish, filter, f)
    figure();
    hold on;
    if (f)
        h_a = plot(t2time(T_azt, T0_azt), filter.applyAdjusted(sig_azt));
    else
        h_a = plot(t2time(T_azt, T0_azt), sig_azt);
    end
    h_a.Color(4) = 0.25;
    ints_azt = utils.detect_signals(T_azt, sig_azt, filter).getAsObjects();
    a_a = zeros(1, length(ints_azt));
    for i = 1:length(ints_azt)
        int = ints_azt(i);
        if (f)
            int.sig = filter.applyAdjusted(int.sig);
        end
        [~, top_i] = max(int.sig);
        m = islocalmin(int.sig, 'MinProminence', 2 * std(int.sig));
        m_is = find(m);
        m_i = m_is(m_is > top_i); m_i = m_i(1);
        a_a(i) = max(int.sig(top_i:m_i)) - min(int.sig(top_i:m_i));
        h_a_l = plot(t2time(int.int(1) + int.T(top_i:m_i), T0_azt), int.sig(top_i:m_i), 'r', 'LineWidth', 2);
    end

    if (f)
        h_g = plot(t2time(T_gaish, T0_gaish), filter.applyAdjusted(sig_gaish));
    else
        h_g = plot(t2time(T_gaish, T0_gaish), sig_gaish);
    end
    h_g.Color(4) = 0.15;
    ints_gaish = utils.detect_signals(T_gaish, sig_gaish, filter).getAsObjects();
    a_g = zeros(1, length(ints_gaish));
    for i = 1:length(ints_gaish)
        int = ints_gaish(i);
        if (f) 
            int.sig = filter.applyAdjusted(int.sig);
        end
        [~, top_i] = max(int.sig);
        m = islocalmin(int.sig, 'MinProminence', 4 * std(int.sig));
        m_is = find(m);
        m_i = m_is(m_is > top_i); m_i = m_i(1);
        a_g(i) = max(int.sig(top_i:m_i)) - min(int.sig(top_i:m_i));
        h_g_l = plot(t2time(int.int(1) + int.T(top_i:m_i), T0_gaish), int.sig(top_i:m_i), 'g', 'LineWidth', 2);
    end
    legend([h_a, h_g, h_a_l, h_g_l], {'AZT', 'GAISH', 'Размах AZT', 'Размах GAISH'});
    set(gca, 'FontSize', 20);
    set(gcf, 'Color', 'w');
    xlabel('Время, сек');
    ylabel('Ускорение мкм/с^2');
    
    fading = a_g ./ a_a;
end