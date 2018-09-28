% Las medidas consisten en barridos desde 35 hasta 75 kHz*. En esta carpeta se incluyen tres barridos diferentes:
%     - vitrex_ind15cm    --> recipiente vitrex en inductor de 15 centímetros de diámetro.* Para este caso no hay medidas a 35 kHz.
%     - zen12_15_cm       --> recipiente zenit-12 en inductor de 15 centímetros de diámetro.
%     - zen12_21_cm       --> recipiente zenit-12 en inductor de 21 centímetros de diámetro.
    
clear all
close all

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
data.il = data_fd.all_var(:,2);
data.il_osc = data.il;
if DEC_FACTOR > 1
    data.il = downsample(data.il,DEC_FACTOR);
end
clear data_fd

data.fs_osc = 50e6;
data.fs = data.fs_osc/DEC_FACTOR;

t = (0:size(data.il,1)-1)/data.fs;
t_osc = (0:size(data.il_osc,1)-1)/data.fs_osc;

dtype = sprintf('(%1$s_ind%2$dcm)',BRAND, DIAMETER);

fsw_legend= sprintf('fsw = %d Hz',data.fsw) ;   


%% IL analysis
figure
plot(t,data.il)
hold on
plot(t_osc, data.il_osc)
%legend(fsw_legend)
title(strcat('il',dtype))
axis tight

% figure
% NFFT = 2^16;
% f= linspace(-data.fs/2,data.fs/2, NFFT) / 1e3;
% ILF = fftshift(fft(data.il,NFFT));
% plot(f, 10*log10(abs(ILF)))
% hold on
% legend(fsw_legend)
% xlabel('f (kHz)')
% title(strcat('IL FFT ',dtype))
% axis tight
figure
pwelch(data.il,[],[],[],data.fs)