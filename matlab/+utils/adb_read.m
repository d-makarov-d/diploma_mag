function [y,par]=adb_read(file_name,data_units,mode);
% function [y,par]=adb_read(file_name,data_units,mode)
% Opened file "file_name" saved as *.adb by DELTA_GEON;
% If time_format = 1, time as datenum,
% If time_format = 0 t_c is file header info structure;
% If data_units = 'c', data in counts,
% If data_units = 'v' - in Volts (default),
% If data_units = 's' - in mkm/sec,
% Returned: t_c - file's first count time;
% y - signal, par - file parameters.
% (Some parameters inside).

snd = 3600*24;  d=4.54;
if nargin<3, mode = 1; if nargin<2,  data_units = 'v';  end,end,
y = []; par = [];
if data_units=='c',
    Koeff = 1;          %counts
    K_sens = [1 1 1 1 1 1 1 1];
elseif data_units=='v',
    Koeff = 0.07*1e-6*d;  %Коефф. преобразования Volts/counts for DELTA-GEON-M
    K_sens = [1 1 1 1 1 1 1 1]; %Output in Volts
elseif data_units=='s',
    Koeff = 0.07*1e-6*d;  %Коефф. преобразования counts/Volts (for L1450 - 10.24/2^13)
    %K_sens = [1e3 1e3 1e3 1 1 1 1 1]/5e3; %SM-3-OS; kmv0540 NZE sensitivity - 2*[3145 3205 3015]
    %K_sens = [2*[3145 3205 3015] 1 1 1 1 1]/1e6; %kmv0540 NZE sensitivity
    K_sens = [2*[400 400 400] 1 1 1 1 1]/1e6; %SPV-3K XYN sensitivity
else,
end,

%header read
nl = 36;    n1 = 15;    n2 = 1; n3 = 4;
fid = fopen(file_name,'r');
par.name = fscanf(fid,'%c',nl);    %имя станции
w = fread(fid,n1,'int16');
par.stn = w(1);    %номер станции
par.prn = w(2);    %номер профиля
par.ptn = w(3);    %номер пункта наблюдения
par.psn = w(4);    %номер пункта взрыва
par.dat = datenum(2000+w(5),w(6),w(7),w(8),w(9),w(10)+w(11)/1e3);    %date, time
par.fs = w(12);    %sample rate
if par.fs<125,	
    if par.fs>60,
        par.fs = 62.5;
    else,
        par.fs = 31.25; 
    end,
end,
par.at1 = w(13);   %attenuate 1
at1 = 100^2/par.at1;
par.at2 = w(14);   %attenuate 2
par.chn = w(15);   %channels number
w = fread(fid,n2,'int32');
par.lng = w;       %record length
w = fread(fid,n3,'int16');
par.fmt = w(1);    %формат отсчетов
par.rct = w(2);    %тип записи (forced, calendar and so on)
par.int = w(3);    %интергатор
par.scl = w(4);    %масштаб
% par
%choose timing
if mode,
    disp(['start time ' datestr(par.dat) ', end time ' datestr(par.dat+par.lng/par.fs/snd)]);
    disp(['bytes ' num2str(par.lng) ', channels ' num2str(par.chn) ', sampling ' num2str(par.fs)]);
    disp(['choose record start time']);
    w = input('for start - ','s');
    if w=='0',
        par.stst = par.dat;
    elseif datenum(w)<=par.dat,
        par.stst = par.dat;
    else,
        par.stst = datenum(w);
    end,
    disp(['choose record length in seconds']);
    par.tmln = str2num(input('time - ','s'));
    par.end = par.stst+par.tmln/snd;
else,
    par.stst = par.dat;
    par.tmln = par.lng/par.fs;  %/par.chn;
end,

%data read
bytes_shift = 4*par.chn*fix((par.stst-par.dat)*snd)*par.fs;%/2)-1;
numbr_count = par.chn*par.fs*par.tmln+par.chn;

fseek(fid,256+bytes_shift,'bof');
x = fread(fid,numbr_count,'int32');

%pause,

if mode,disp(['bytes_shift ' num2str(bytes_shift) ', in seconds ' num2str(bytes_shift/4/par.chn/par.fs)]);end,
%channeling
for i=1:par.chn,
    %y(:,i) = Koeff* x((i-1)*fix(numbr_count/par.chn)+1+i:i*fix(numbr_count/par.chn)+i-par.chn) /K_sens(i)/par.at1;
    y(:,i) = Koeff* x((i-1)*par.lng+1+i:i*par.lng+i-par.chn) /K_sens(i)/at1;
end,    

%+1 start on 20.02.11 ?



fclose(fid);
