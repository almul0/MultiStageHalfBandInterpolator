% Las medidas consisten en barridos desde 35 hasta 75 kHz*. En esta carpeta se incluyen tres barridos diferentes:
%     - vitrex_ind15cm    --> recipiente vitrex en inductor de 15 centímetros de diámetro.* Para este caso no hay medidas a 35 kHz.
%     - zen12_15_cm       --> recipiente zenit-12 en inductor de 15 centímetros de diámetro.
%     - zen12_21_cm       --> recipiente zenit-12 en inductor de 21 centímetros de diámetro.
    
clear all
%close all

BRAND = 'zen12';
DIAMETER = 21;
% FSW en un valor entre los siguientes:
% 35000, 40000, 45000, 50000, 55000, 60000, 65000, 70000, 75000
FSW = 35e3;
DEC_FACTOR=50;
%DIAMETER = 'zen12_ind15cm';
%DIAMETER = 'vitrex_ind15cm';


data = {};
data.fsw = FSW;

data_fd = load(sprintf('../oscilloscope_measurements/%1$s_ind%2$dcm/%1$s_%2$dcm_%3$dHz.mat', BRAND, DIAMETER, data.fsw)); 

data.fs_osc = 50e6;
data.fs = data.fs_osc/DEC_FACTOR;

data.il = data_fd.all_var(:,2);
data.il_osc = data.il;

data.t_osc = 0:1/data.fs_osc:(size(data.il_osc,1)-1)/data.fs_osc;
data.t = 0:1/data.fs:(size(data.il_osc,1)-1)/data.fs_osc;

%data.il = resample(data.il,1,DEC_FACTOR);
data.il = resample(data.il,data.t_osc,data.fs);

clear data_fd



data.t_str = 't(\mus)';

data.dtype = sprintf('(%1$s_ind%2$dcm)',BRAND, DIAMETER);

data.fsw_legend= sprintf('fsw = %d Hz',data.fsw) ;   

%% Upsampling specs

data.fs_dest = 8*1e6; 
L=round(data.fs_dest/data.fs);

% Zero insertion
%il_L = kron(data.il,[1 zeros(1,L-1)]');

data.t_dest = 0:1/data.fs_dest:(size(data.il_osc,1)-1)/data.fs_osc;
%il_L_plot = il_L;
%il_L_plot(il_L  == 0) = NaN;

%[P,Q] = rat(1/(data.fs_osc/data.fs_dest));
%data.il_dest = resample(data.il_osc, P, Q, 30);
data.il_dest = resample(data.il_osc, data.t_osc, data.fs_dest);
clear P
clear Q

%% IL analysis

figure
plot(data.t,data.il, 'DisplayName', 'Source')
hold on
plot(data.t_dest, data.il_dest, 'DisplayName', 'Target')
plot(data.t_osc, data.il_osc, 'DisplayName', 'Original')
%legend(fsw_legend)
title(strcat('il ',data.dtype))
axis tight

%% Frequency spectra
figure
NFFT = 2^16;
f= linspace(-data.fs/2,data.fs/2, NFFT) / 1e3;
f_osc= linspace(-data.fs_osc/2,data.fs_osc/2, NFFT) / 1e3;
f_dest = linspace(-data.fs_dest/2,data.fs_dest/2, NFFT) / 1e3;
IL_F = fftshift(fft(data.il,NFFT));
ILOSC_F = fftshift(fft(data.il_osc,NFFT));
ILD_F = fftshift(fft(data.il_dest,NFFT));
plot(f, 10*log10(abs(IL_F)/max(abs(IL_F))),'DisplayName', 'Decimated')
hold on
plot(f_dest, 10*log10(abs(ILD_F)/max(abs(ILD_F))),'DisplayName', 'Target')
plot(f_osc, 10*log10(abs(ILOSC_F)/max(abs(ILOSC_F))), 'DisplayName', 'Original')
hold on
xlabel('f (kHz)')
title(strcat('IL FFT ',data.dtype))
axis tight
xlim([-data.fs/2 data.fs/2]/1e3)
clear f
clear f_osc
clear f_dest
%%
figure
pwelch(data.il,[],[],[],data.fs)
pwelch(data.il_osc,[],[],[],data.fs_osc)
pwelch(data.il_dest,[],[],[],data.fs_dest)