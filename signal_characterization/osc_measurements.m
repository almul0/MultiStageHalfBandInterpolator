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
FSW = 75e3;
% FSW = 40e3;
% FSW = 45e3;
% FSW = 50e3;
% FSW = 55e3;
% FSW = 60e3;
% FSW = 65e3;
% FSW = 70e3;
% FSW = 75e3;


FS_OSCILLOSCOPE = 50; % MHz

L = 6;

FS_DST = 100/6; % MHz

data = {};
data.fsw = FSW;
fprintf('Frecuencia de resonancia (fsw): %.4f KHz\n', data.fsw/1e3)

% Load data
data_fd = load(sprintf('../oscilloscope_measurements/%1$s_ind%2$dcm/%1$s_%2$dcm_%3$dHz.mat', BRAND, DIAMETER, data.fsw)); 

data.t_str = 't(\mus)';

data.dtype = sprintf('(%1$s\\_ind%2$dcm)',BRAND, DIAMETER);

data.fsw_legend= sprintf('fsw = %d Hz',data.fsw) ;

% Set oscilloscope fs
data.osc.fs = FS_OSCILLOSCOPE*1e6;

% Set simulated source fs
data.adc.fs = 1e6*FS_DST/L;
fprintf('Frecuencia de origen (fs): %.4f MHz\n', data.adc.fs/1e6)

% Set simulated target fs
data.dst.fs = FS_DST*1e6;
fprintf('Frecuencia de dstino (fs_dst): %.4f MHz\n', data.dst.fs/1e6)

% Interpolation factor
R=round(data.dst.fs/data.adc.fs);
fprintf('Factor de interpolación (R): %d\n', R)

data.osc.il = data_fd.all_var(:,2);
data.osc.vo = data_fd.all_var(:,4);
data.osc.vc = data_fd.all_var(:,3);
data.osc.vbus = data_fd.all_var(:,1);
data.osc.label = 'Oscilloscope';


% Signal accomodation
% Remuestreo utilizando un filtro polifase de antialiasing
% a la frecuencia de dstino
[P,Q] = rat(1/(data.osc.fs/data.dst.fs));
[data.dst.il, data.dst.b_res ] = resample(data.osc.il,P,Q);
data.dst.vo= resample(data.osc.vo,P,Q, data.dst.b_res);
data.dst.vc = resample(data.osc.vc,P,Q, data.dst.b_res);
data.dst.vbus = resample(data.osc.vbus,P,Q, data.dst.b_res);
data.dst.label = 'Target';

% De la frecuencia de dstino remuestreo utilizando un filtro 
% polifase de antialiasing a la frecuencia de origen
[P,Q] = rat(1/(data.dst.fs/data.adc.fs));
[data.adc.il, data.adc.b_res] = resample(data.dst.il,P,Q);
data.adc.vo= resample(data.dst.vo,P,Q,data.adc.b_res);
data.adc.vc = resample(data.dst.vc,P,Q, data.adc.b_res);
data.adc.vbus = resample(data.dst.vbus,P,Q, data.adc.b_res);
data.adc.label = 'Source';

% Obtención de los instantes temporales de la señales
data.osc.t = 0:1/data.osc.fs:(size(data.osc.il,1)-1)/data.osc.fs;
data.dst.t = 0:1/data.dst.fs:(size(data.dst.il,1)-1)/data.dst.fs;
data.adc.t = 0:1/data.adc.fs:(size(data.adc.il,1)-1)/data.adc.fs;

clear FSW
clear FS_OSCILLOSCOPE
clear FS_SOURCE_FACTOR
clear FS_TARGET_FACTOR
clear data_fd
clear P
clear Q
%%

% Zero insertion and RMS
il_R = kron(data.il,[1 zeros(1,R-1)]');
fprintf('Source RMS: %.4f\n', rms(data.il_dst-il_R));

%% Frequency spectra
interpolation_freq_spectra(data)

%% Extracción de paramétros temporales
ss = data.dst;


nperiods = 32;
nperiod2 = round(nperiods*(ss.fs/data.fsw)/2);
nstart = ceil(size(ss.il,1)/2)-(nperiod2)-round((ss.fs/data.fsw)/8);
nend = ceil(size(ss.il,1)/2)+(nperiod2)-round((ss.fs/data.fsw)/8);

l = size(ss.il,1);
l099 = (round(l*0.005):round(l*0.995));
ss.il_rms = rms(l099);
ss.p_avg = mean(ss.il(l099).*ss.vo(l099));

il_range = ss.il(nstart:nend);
vo_range = ss.vo(nstart:nend);
vc_range = ss.vc(nstart:nend);
vbus_range = ss.vbus(nstart:nend);
t_range = ss.t(nstart:nend);

[ss.ilpkh_locs, ss.ilpkl_locs] = peak_cicle_detector(il_range, ss.fs, data.fsw);
numel(ss.ilpkh_locs)
numel(ss.ilpkl_locs)
ss.ilpkh = il_range(ss.ilpkh_locs);
ss.ilpkl = il_range(ss.ilpkl_locs);
figure
hold on
plot(t_range, il_range,'r', 'DisplayName', 'i_L')
plot(t_range(ss.ilpkh_locs), il_range(ss.ilpkh_locs), 'r', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None')
plot(t_range(ss.ilpkl_locs), il_range(ss.ilpkl_locs), 'r', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None')


[ss.rise_locs, ss.fall_locs] = igbt_edge_detector(vo_range, vbus_range);

[ss.ioffh, ss.ioffl] = off_transition_current(il_range, ss.rise_locs, ss.fall_locs);

figure
hold on
yyaxis left
plot(t_range, vo_range,':b','DisplayName', 'v_{bus}')

plot(t_range(ss.rise_locs), vo_range(ss.rise_locs), 'b', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 'Flanco subida')
plot(t_range(ss.fall_locs), vo_range(ss.fall_locs), 'b', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 'Flanco bajada')
ylabel('Vc')
yyaxis right
plot(t_range, il_range,'r','DisplayName','i_L')
plot(t_range(ss.rise_locs), il_range(ss.rise_locs), 'r', ...
    'Marker', '^', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 'Flanco subida')
plot(t_range(ss.fall_locs), il_range(ss.fall_locs), 'r', ...
    'Marker', 'v', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 'Flanco bajada')
ylabel('Il')
xlabel('t(s)')
axis tight

[ss.tsnbh_locs, ss.tsnbl_locs] = snbcap_discharge_time(il_range, vbus_range, ss.fs, ss.rise_locs, ss.fall_locs);

ss.tsnbh = 1/ss.fs * (ss.tsnbh_locs-ss.fall_locs);
ss.tsnbl = 1/ss.fs * (ss.tsnbl_locs-ss.rise_locs);
plot(t_range(ss.tsnbh_locs), il_range(ss.tsnbh_locs), 'g', ...
    'Marker', 'o', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 't_{snb,H}')
plot(t_range(ss.tsnbl_locs), il_range(ss.tsnbl_locs), 'g', ...
    'Marker', 'o', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 't_{snb,L}')



mzd = round(0.2*ss.fs/data.fsw);
[ss.zc_locs] = zero_crossing(il_range,mzd,0);

[ss.tdh_locs, ss.tdl_locs] = diode_driving_time(ss.zc_locs, ss.tsnbh_locs, ss.tsnbl_locs);
ss.tdh = (ss.tdh_locs - ss.tsnbh_locs)/ss.fs;
ss.tdl = (ss.tdl_locs - ss.tsnbl_locs)/ss.fs;


plot(t_range(ss.zc_locs), il_range(ss.zc_locs), 'k', ...
    'Marker', 's', 'LineWidth',2, 'LineStyle', 'None','DisplayName', 'zero cross')

%% Quality measurements comparison
interpolation_quality(data.adc,data.dst,0,data.fsw,1)




