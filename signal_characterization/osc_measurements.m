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
data.osc.fs = FS_OSCILLOSCOPE;

% Set simulated source fs
data.adc.fs = FS_OSCILLOSCOPE*FS_SOURCE_FACTOR;
fprintf('Frecuencia de origen (fs): %.4f MHz\n', data.adc.fs/1e6)

% Set simulated target fs
data.dst.fs = FS_OSCILLOSCOPE*FS_TARGET_FACTOR;
fprintf('Frecuencia de dstino (fs_dst): %.4f MHz\n', data.dst.fs/1e6)

% Interpolation factor
R=round(data.dst.fs/data.adc.fs);
fprintf('Factor de interpolación (R): %d\n', R)

data.osc.il = data_fd.all_var(:,2);
data.osc.vo = data_fd.all_var(:,4);
data.osc.vc = data_fd.all_var(:,3);
data.osc.vbus = data_fd.all_var(:,1);


% Signal accomodation
% Remuestreo utilizando un filtro polifase de antialiasing
% a la frecuencia de dstino
[P,Q] = rat(1/(data.osc.fs/data.dst.fs));
[data.dst.il, data.dst.b_res ] = resample(data.osc.il,P,Q);
data.dst.vo= resample(data.osc.vo,P,Q, data.dst.b_res);
data.dst.vc = resample(data.osc.vc,P,Q, data.dst.b_res);
data.dst.vbus = resample(data.osc.vbus,P,Q, data.dst.b_res);

% De la frecuencia de dstino remuestreo utilizando un filtro 
% polifase de antialiasing a la frecuencia de origen
[P,Q] = rat(1/(data.dst.fs/data.adc.fs));
[data.adc.il, data.adc.b_res] = resample(data.dst.il,P,Q);
data.adc.vo= resample(data.dst.vo,P,Q,data.adc.b_res);
data.adc.vc = resample(data.dst.vc,P,Q, data.adc.b_res);
data.adc.vbus = resample(data.dst.vbus,P,Q, data.adc.b_res);

% Obtención de los instantes temporales de la señales
data.osc.t = 0:1/data.osc.fs:(size(data.osc.il,1)-1)/data.osc.fs;
data.dst.t = 0:1/data.dst.fs:(size(data.dst.il,1)-1)/data.dst.fs;
data.adc.t = 0:1/data.adc.fs:(size(data.adc.il,1)-1)/data.adc.fs;

clear data_fd
clear P
clear Q
%%

% Zero insertion and RMS
il_R = kron(data.il,[1 zeros(1,R-1)]');
fprintf('Source RMS: %.4f\n', rms(data.il_dst-il_R));

%% IL analysis & Zero Crossing

%% Frequency spectra
figure
NFFT = 2^16;
f= linspace(-data.adc.fs/2,data.adc.fs/2, NFFT) / 1e3;
f_osc= linspace(-data.osc.fs/2,data.osc.fs/2, NFFT) / 1e3;
f_dst = linspace(-data.dst.fs/2,data.dst.fs/2, NFFT) / 1e3;
IL_F = fftshift(fft(data.adc.il,NFFT));
ILOSC_F = fftshift(fft(data.osc.il,NFFT));
ILD_F = fftshift(fft(data.dst.il,NFFT));
plot(f_osc, 10*log10(abs(ILOSC_F)/max(abs(ILOSC_F))), 'DisplayName', 'Original')
hold on
plot(f_dst, 10*log10(abs(ILD_F)/max(abs(ILD_F))),'DisplayName', 'Target')
plot(f, 10*log10(abs(IL_F)/max(abs(IL_F))),'DisplayName', 'Decimated')
xlabel('f (kHz)')
title(strcat('IL FFT ',data.dtype))
axis tight
%xlim([-data.fs/2 data.fs/2]/1e3)
legend
clear f
clear f_osc
clear f_dst

%% Extracción de paramétros temporales
ss = data.int;


nperiods = 32;
nperiod = round(nperiods*(1/data.fsw)*ss.fs);
nstart = ceil(size(ss.il,1)/2)-(nperiod/2);
nend = ceil(size(ss.il,1)/2)+(nperiod/2);


ss.il_rms = rms(ss.il);
ss.p_avg = mean(ss.il.*ss.vo);

il_range = ss.il(nstart:nend);
vo_range = ss.vo(nstart:nend);
vc_range = ss.vc(nstart:nend);
vbus_range = ss.vbus(nstart:nend);
t_range = ss.t(nstart:nend);

[ss.ilpkh_locs, ss.ilpkl_locs] = peak_cicle_detector(il_range, ss.fs, data.fsw);
ss.ilpkh = il_range(ss.ilpkh_locs);
ss.ilpkl = il_range(ss.ilpkl_locs);
figure
hold on
plot(t_range, il_range,'r')
plot(t_range(ss.ilpkh_locs), il_range(ss.ilpkh_locs), 'r', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
plot(t_range(ss.ilpkl_locs), il_range(ss.ilpkl_locs), 'r', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')


[ss.rise_locs, ss.fall_locs] = igbt_edge_detector(vo_range, vbus_range);

[ss.ioffh, ss.ioffl] = off_transition_current(il_range, ss.rise_locs, ss.fall_locs);

figure
hold on
yyaxis left
plot(t_range, vo_range,':b')

plot(t_range(ss.rise_locs), vo_range(ss.rise_locs), 'b', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')
plot(t_range(ss.fall_locs), vo_range(ss.fall_locs), 'b', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
ylabel('Vc')
yyaxis right
plot(t_range, il_range,'r')
plot(t_range(ss.rise_locs), il_range(ss.rise_locs), 'r', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')
plot(t_range(ss.fall_locs), il_range(ss.fall_locs), 'r', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
ylabel('Il')
xlabel('t(s)')
axis tight

[ss.tsnbh_locs, ss.tsnbl_locs] = snbcap_discharge_time(il_range, vbus_range, ss.fs, ss.rise_locs, ss.fall_locs);

ss.tsnbh = 1/ss.fs * (ss.tsnbh_locs-ss.fall_locs);
ss.tsnbl = 1/ss.fs * (ss.tsnbl_locs-ss.rise_locs);
plot(t_range(ss.tsnbh_locs), il_range(ss.tsnbh_locs), 'r', ...
    'Marker', 'o', 'LineWidth',2, 'LineStyle', 'None')
plot(t_range(ss.tsnbl_locs), il_range(ss.tsnbl_locs), 'g', ...
    'Marker', 'o', 'LineWidth',2, 'LineStyle', 'None')



mzd = round(0.2*ss.fs/data.fsw);
[ss.zc_locs] = zero_crossing(il_range,mzd,0);

[ss.tdh_locs, ss.tdl_locs] = diode_driving_time(ss.zc_locs, ss.tsnbh_locs, ss.tsnbl_locs);
ss.tdh = (ss.tdh_locs - ss.tsnbh_locs)/ss.fs;
ss.tdl = (ss.tdl_locs - ss.tsnbl_locs)/ss.fs;


plot(t_range(ss.zc_locs), il_range(ss.zc_locs), 'k', ...
    'Marker', 's', 'LineWidth',2, 'LineStyle', 'None')

%% Quality measurements comparison
s1 = data.dst;
s2 = data.adc;

fprintf('%d KHz\tmean\tstd\tmin\tmax\n', data.fsw/1e3)
fprintf('e_ilrms\t%.4f\n', abs(s1.il_rms-s2.il_rms));
fprintf('e_pavg\t%.4f\n', abs(s1.p_avg-s2.p_avg));
ilpkh_stats = datastats(abs(s1.ilpkh-s2.ilpkh));
fprintf('ilpk,H\t%.1e\t%.1e\t%.1e\t%.1e\n',ilpkh_stats.mean, ilpkh_stats.std, ilpkh_stats.min, ilpkh_stats.max);

ioffh_stats = datastats(abs(s1.ioffh-s2.ioffh));
fprintf('ioff,H\t%.1e\t%.1e\t%.1e\t%.1e\n',ioffh_stats.mean, ioffh_stats.std, ioffh_stats.min, ioffh_stats.max);

ioffl_stats = datastats(abs(s1.ioffl-s2.ioffl));
fprintf('ioff,L\t%.1e\t%.1e\t%.1e\t%.1e\n',ioffl_stats.mean, ioffl_stats.std, ioffl_stats.min, ioffl_stats.max);

tsnbh_stats = datastats(abs(s1.tsnbh-s2.tsnbh));
fprintf('tsnb,H\t%.1e\t%.1e\t%.1e\t%.1e\n',tsnbh_stats.mean, tsnbh_stats.std, tsnbh_stats.min, tsnbh_stats.max);

tsnbl_stats = datastats(abs(s1.tsnbl-s2.tsnbl));
fprintf('tsnb,L\t%.1e\t%.1e\t%.1e\t%.1e\n',tsnbl_stats.mean, tsnbl_stats.std, tsnbl_stats.min, tsnbl_stats.max);

tdh_stats = datastats(abs(s1.tdh-s2.tdh));
fprintf('td,H\t%.1e\t%.1e\t%.1e\t%.1e\n',tdh_stats.mean, tdh_stats.std, tdh_stats.min, tdh_stats.max);

tdl_stats = datastats(abs(s1.tdl-s2.tdl));
fprintf('td,L\t%.1e\t%.1e\t%.1e\t%.1e\n',tdl_stats.mean, tdl_stats.std, tdl_stats.min, tdl_stats.max);




