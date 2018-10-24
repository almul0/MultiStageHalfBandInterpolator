% Las medidas consisten en barridos desde 35 hasta 75 kHz*. En esta carpeta se incluyen tres barridos diferentes:
%     - vitrex_ind15cm    --> recipiente vitrex en inductor de 15 centímetros de diámetro.* Para este caso no hay medidas a 35 kHz.
%     - zen12_15_cm       --> recipiente zenit-12 en inductor de 15 centímetros de diámetro.
%     - zen12_21_cm       --> recipiente zenit-12 en inductor de 21 centímetros de diámetro.
    
clear all
clc
close all
%BRAND = 'vitrex_ind'
BRAND = 'zen12';

%DIAMETER = 15;
DIAMETER = 21;

% FSW en un valor entre los siguientes:
% 35000, 40000, 45000, 50000, 55000, 60000, 65000, 70000, 75000
FSW = 35e3;
% FSW = 40e3;
% FSW = 45e3;
% FSW = 50e3;
% FSW = 55e3;
% FSW = 60e3;
% FSW = 65e3;
% FSW = 70e3;
% FSW = 75e3;


FS_OSCILLOSCOPE = 50e6;
% 
FS_SOURCE_FACTOR = 1/18; % 100/36 MHz

%FS_TARGET_FACTOR = 1/9; % R = 2
FS_TARGET_FACTOR = 1/3; % R = 6
% FS_TARGET_FACTOR = 4/9; % R = 8
% FS_TARGET_FACTOR = 8/9; % R = 16


%FS_SOURCE_FACTOR = 1/50; % 1 MHz
% 
% FS_TARGET_FACTOR = 1/25; % R = 2
% FS_TARGET_FACTOR = 2/25; % R = 4
% FS_TARGET_FACTOR = 6/50; % R = 4
%FS_TARGET_FACTOR = 4/25; % R = 8
%FS_TARGET_FACTOR = 8/25; % R = 16

data = {};
data.fsw = FSW;
fprintf('Frecuencia de resonancia (fsw): %.4f KHz\n', data.fsw/1e3)

% Load data
data_fd = load(sprintf('../oscilloscope_measurements/%1$s_ind%2$dcm/%1$s_%2$dcm_%3$dHz.mat', BRAND, DIAMETER, data.fsw)); 

data.t_str = 't(\mus)';

data.dtype = sprintf('(%1$s\\_ind%2$dcm)',BRAND, DIAMETER);

data.fsw_legend= sprintf('fsw = %d Hz',data.fsw) ;

% Set oscilloscope fs
data.fs_osc = FS_OSCILLOSCOPE;

% Set simulated source fs
data.fs = FS_OSCILLOSCOPE*FS_SOURCE_FACTOR;
fprintf('Frecuencia de origen (fs): %.4f MHz\n', data.fs/1e6)

% Set simulated target fs
data.fs_dest = FS_OSCILLOSCOPE*FS_TARGET_FACTOR;
fprintf('Frecuencia de destino (fs_dest): %.4f MHz\n', data.fs_dest/1e6)

% Interpolation factor
R=round(data.fs_dest/data.fs);
fprintf('Factor de interpolación (R): %d\n', R)

data.il_osc = data_fd.all_var(:,2);
data.vo_osc = data_fd.all_var(:,4);
data.vc_osc = data_fd.all_var(:,3);
data.vbus_osc = data_fd.all_var(:,1);


% Signal accomodation
% Remuestreo utilizando un filtro polifase de antialiasing
% a la frecuencia de destino
[P,Q] = rat(1/(data.fs_osc/data.fs_dest));
data.il_dest = resample(data.il_osc,P,Q);

% De la frecuencia de destino remuestreo utilizando un filtro 
% polifase de antialiasing a la frecuencia de origen
[P,Q] = rat(1/(data.fs_dest/data.fs));
data.il = resample(data.il_dest,P,Q);

% Obtención de los instantes temporales de la señales
data.t_osc = 0:1/data.fs_osc:(size(data.il_osc,1)-1)/data.fs_osc;
data.t_dest = 0:1/data.fs_dest:(size(data.il_dest,1)-1)/data.fs_dest;
data.t = 0:1/data.fs:(size(data.il,1)-1)/data.fs;

clear data_fd
clear P
clear Q
%%

% Zero insertion and RMS
il_R = kron(data.il,[1 zeros(1,R-1)]');
fprintf('Source RMS: %.4f\n', rms(data.il_dest-il_R));

%% IL analysis & Zero Crossing
cicle_n = round(0.2*data.fs/data.fsw);
[zc_locs] = zero_crossing(data.il, cicle_n, 0);
cicle_n = round(0.2*data.fs_dest/data.fsw);
[zcl_dest] = zero_crossing(data.il_dest, cicle_n);
cicle_n = round(0.2*data.fs_osc/data.fsw);
[zcl_osc] = zero_crossing(data.il_osc, cicle_n);
figure
plot(data.t_osc,data.il_osc, 'k', 'DisplayName', sprintf('%.4fMHz', data.fs_osc/1e6))
hold on
plot(data.t_dest,data.il_dest, ':','Marker', '.', 'LineWidth', 2,'LineStyle', 'none', 'DisplayName', sprintf('%.4fMHz', data.fs_dest/1e6))
plot(data.t,data.il, 'r', 'DisplayName', sprintf('%.4fMHz', data.fs/1e6))

zc_t = ((zc_locs-1)/data.fs);
zc_dest_t = ((zcl_dest-1)/data.fs_dest);
zc_osc_t = ((zcl_osc-1)/data.fs_osc);
plot(zc_t,ones(size(zc_t)).*data.il(zc_locs),'Marker','x','LineStyle', 'none');
plot(zc_dest_t,zeros(size(zc_dest_t)),'Marker','*','LineStyle', 'none');
plot(zc_osc_t,zeros(size(zc_osc_t)),'Marker','o','LineStyle', 'none');
axis tight;
legend;
title(sprintf('Señales %s a %.2f kHz remuestreadas', data.dtype, data.fsw/1e3))

%% Frequency spectra
figure
NFFT = 2^16;
f= linspace(-data.fs/2,data.fs/2, NFFT) / 1e3;
f_osc= linspace(-data.fs_osc/2,data.fs_osc/2, NFFT) / 1e3;
f_dest = linspace(-data.fs_dest/2,data.fs_dest/2, NFFT) / 1e3;
IL_F = fftshift(fft(data.il,NFFT));
ILOSC_F = fftshift(fft(data.il_osc,NFFT));
ILD_F = fftshift(fft(data.il_dest,NFFT));
plot(f_osc, 10*log10(abs(ILOSC_F)/max(abs(ILOSC_F))), 'DisplayName', 'Original')
hold on
plot(f_dest, 10*log10(abs(ILD_F)/max(abs(ILD_F))),'DisplayName', 'Target')
plot(f, 10*log10(abs(IL_F)/max(abs(IL_F))),'DisplayName', 'Decimated')
xlabel('f (kHz)')
title(strcat('IL FFT ',data.dtype))
axis tight
%xlim([-data.fs/2 data.fs/2]/1e3)
legend
clear f
clear f_osc
clear f_dest

%% Extracción de paramétros temporales
il = data.il_osc;
vo = data.vo_osc;
vbus = data.vbus_osc;
fsw = data.fsw;
fs = data.fs_osc;
t = data.t_osc;

nperiods = 32
nperiod = round(nperiods*(1/fsw)*fs);
nstart = ceil(size(il,1)/2)-(nperiod/2);
nend = ceil(size(il,1)/2)+(nperiod/2);


ilrms = rms(il);
pavg = mean(il.*vo);

[ilpkh_locs, ilpkl_locs] = peak_cicle_detector(il, fs, fsw);
ilpkh_intval = ilpkh_locs(ilpkh_locs>=nstart & ilpkh_locs<=nend);
ilpkl_intval = ilpkl_locs(ilpkl_locs>=nstart & ilpkl_locs<=nend);
figure
hold on
plot(t(nstart:nend), il(nstart:nend),'r')
plot(t(ilpkh_intval), il(ilpkh_intval), 'r', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
plot(t(ilpkl_intval), il(ilpkl_intval), 'r', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')


[rise_locs, fall_locs] = igbt_edge_detector(vo, vbus);
rlocs_intval = rise_locs(rise_locs>=nstart & rise_locs<=nend);
flocs_intval = fall_locs(fall_locs>=nstart & fall_locs<=nend);

[ioffh, ioffl] = off_transition_current(data.il_osc, rise_locs, fall_locs);
figure
hold on
yyaxis left
%plot(data.t_osc(n2start:n2end), data.vc_osc(n2start:n2end),'b')
plot(t(nstart:nend), vo(nstart:nend),':b')
%plot(data.t_osc(n2start:n2end), data.vbus_osc(n2start:n2end),'k')

plot(t(rlocs_intval), vo(rlocs_intval), 'b', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')
plot(t(flocs_intval), vo(flocs_intval), 'b', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
ylabel('Vc')
yyaxis right
plot(t(nstart:nend), il(nstart:nend),'r')
plot(t(rlocs_intval), il(rlocs_intval), 'r', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')
plot(t(flocs_intval), il(flocs_intval), 'r', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
ylabel('Il')
xlabel('t(s)')
axis tight

[tsnbh_locs, tsnbl_locs] = snbcap_discharge_time(il, vbus, fs, rise_locs, fall_locs);
tsnbh_intval = tsnbh_locs(tsnbh_locs>=nstart & tsnbh_locs<=nend);
tsnbl_intval = tsnbl_locs(tsnbl_locs>=nstart & tsnbl_locs<=nend);

tnsbh = 1/data.fs_osc * (tsnbh_locs-fall_locs);
tnsbl = 1/data.fs_osc * (tsnbl_locs-rise_locs);
plot(t(tsnbh_intval), il(tsnbh_intval), 'k', ...
    'Marker', 'o', 'LineWidth',2, 'LineStyle', 'None')
plot(t(tsnbl_intval), il(tsnbl_intval), 'g', ...
    'Marker', 'o', 'LineWidth',2, 'LineStyle', 'None')



mzd = round(0.2*data.fs_osc/data.fsw);
[zc_locs] = zero_crossing(data.il_osc,mzd,0);
zc_intval = zc_locs(zc_locs>=nstart & zc_locs<=nend);

[tdhn, tdln] = diode_driving_time(zc_locs, tsnbh_locs, tsnbl_locs);
plot(t(zc_intval), il(zc_intval), 'k', ...
    'Marker', 's', 'LineWidth',2, 'LineStyle', 'None')





