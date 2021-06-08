clear
[y, par] = utils.adb_read('seismic_data/metro_1/30460002.adb', 's', 0);

trn.z = (y(:,3)-mean(y(:,3)))' / 1e6;
trn.x = (y(:,1)-mean(y(:,1)))' / 1e6;
trn.y = (y(:,2)-mean(y(:,2)))' / 1e6;
trn.t = (0:length(y)-1) / par.fs / 60;      %time in minutes

% load data from mobile (to variable acc)
load('C:\Users\Danil_win\Documents\FF\diploma_mag\matlab\patterns\mob_acc.mat');

% index of intervals when ride
int_mob(1,:) = [96202, 163722];
int_trn(1,:) = [84629, 127129];
int_mob(2,:) = [241726, 314633];
int_trn(2,:) = [175290, 220302];
int_mob(3,:) = [362275, 437441];
int_trn(3,:) = [250401, 297243];
int_mob(4,:) = [539021, 621941];
int_trn(4,:) = [350537, 412198];

vars = {'x', 'y', 'z', 't'};
for i=1:size(int_mob, 1)
    mob = struct();
    azt = struct();
    for i_v = 1:length(vars)
        field_name = vars{i_v};
        field_mob = getfield(acc, field_name);
        field_trn = getfield(trn, field_name);
        mob = setfield(mob, vars{i_v}, field_mob(int_mob(i, 1):int_mob(i, 2)));
        azt = setfield(azt, vars{i_v}, field_trn(int_trn(i, 1):int_trn(i, 2)));
    end
    rec(i).mob = mob;
    rec(i).azt = azt;
end

figure
vec.x = cumtrapz(correct(rec(1).azt.x));
vec.y = cumtrapz(correct(rec(1).azt.y));
vec.z = cumtrapz(correct(rec(1).azt.z));
plot(rec(1).azt.t, len(vec) * 3.6)
title('V')

figure
spec = abs(fft(correct(rec(1).azt.z)));
h_len = length(spec) / 2 + 1;
plot(linspace(0, 62.5/2, h_len), spec(1:h_len));


function a = correct(sig)
    a = sig - mean(sig);
end

function l = len(vec)
    l = sqrt(vec.x .^ 2 + vec.y .^ 2 + vec.z .^ 2);
end