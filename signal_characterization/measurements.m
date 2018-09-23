% Dos esctructuras, una para el inductor '1' de 21 cm y otra para el '2' de
% 15 cm. Así, en la esctructura de 21 cm, las medidas vo2, il2 y vc2 son 
% irrelevantes y viceversa.
% En la estructura se añade información adicional como: frecuencia de 
% muestreo, condensador de resonancia, condensador de snubber, recipiente, 
% dispositivo y ganancias de filtros analógicos.
% Las medidas están ordenadas en frecuencias crecientes. La frecuencia de 
% conmutación se puede consultar en myStruc.fsw(i) (correspondencia por 
% columnas con las medidas de los ADCs).
% Las medidas están en el formato que tienen en FPGA <w,q> "signed <18,5>".
% Para obtener las señales en magnitudes del S.I. la conversión es:
% [S.I] = [ADC]*2^-5*(refADC/2^n)/analogGain
% donde
% refADC = 3.3 -> referencia ADCs [V]
% 2^n -> n = nbits = 12

clear all
close all
refADC = 3.3;
n=12;

data21 = load('../medidas/struc_21cm.mat');
data21 = data21.myStruc;
data21.vo = data21.vo1;
data21.il = data21.il1;
data21.vc = data21.vc1;
data21 = rmfield(data21,'vo1');
data21 = rmfield(data21,'il1');
data21 = rmfield(data21,'vc1');
data21 = rmfield(data21,'vo2');
data21 = rmfield(data21,'il2');
data21 = rmfield(data21,'vc2');

data21.il_si = data21.il*2^-5*(refADC/2^n)/data21.G_il;
data21.vo_si = data21.il*2^-5*(refADC/2^n)/data21.G_vo;
data21.vc_si = data21.il*2^-5*(refADC/2^n)/data21.G_vc;


data15 = load('../medidas/struc_15cm.mat');
data15 = data15.myStruc;
data15.vo = data15.vo2;
data15.il = data15.il2;
data15.vc = data15.vc2;
data15 = rmfield(data15,'vo1');
data15 = rmfield(data15,'il1');
data15 = rmfield(data15,'vc1');
data15 = rmfield(data15,'vo2');
data15 = rmfield(data15,'il2');
data15 = rmfield(data15,'vc2');

data15.il_si = data15.il*2^-5*(refADC/2^n)/data15.G_il;
data15.vo_si = data15.il*2^-5*(refADC/2^n)/data15.G_vo;
data15.vc_si = data15.il*2^-5*(refADC/2^n)/data15.G_vc;

fs = 100/36*1e6;

%% Diameter selection

DIAMETER = 21;

if DIAMETER == 21 
    data = data21;
else 
    DIAMETER = 15;
    data = data15;
end

dtype = strcat(data.Pot, '(',num2str (DIAMETER,'%d'),'cm)')

%% Frequency selection

%  (21cm)         (15cm)
% 1 = 35000     1 = 45000
% 2 = 40000     2 = 50000
% 3 = 45000     3 = 55000
% 4 = 50000     4 = 60000
% 5 = 55000     5 = 65000
% 6 = 60000     6 = 70000
% 7 = 65000     7 = 75000
% 8 = 70000
% 9 = 75000
fsw_idx = 7;

fsw_legend=cell(size(data.fsw,2),1);%  two positions 
for i=1:size(data.fsw,2)
    fsw_legend{i}= sprintf('fsw = %d',data.fsw(i)) ;   
end

%% Show data

t = (0:size(data.vmains,1)-1)/fs;

figure
plot(t,data.vmains(:,fsw_idx))
legend(fsw_legend{fsw_idx})
title(strcat('vmains ',dtype))

figure
plot(t,data.imains(:,fsw_idx))
legend(fsw_legend{fsw_idx})
title(strcat('imains ',dtype))

figure
plot(t,data.vbus(:,fsw_idx))
legend(fsw_legend{fsw_idx})
title(strcat('vbus',dtype))

figure
plot(t,data.vo(:,fsw_idx))
legend(fsw_legend{fsw_idx})
title(strcat('vo',dtype))

figure
plot(t,data.il(:,fsw_idx))
legend(fsw_legend{fsw_idx})
title(strcat('il',dtype))

figure
plot(t,data.vc(:,fsw_idx))
legend(fsw_legend{fsw_idx})
title(strcat('vc ',dtype))

%% IL analysis
fsw_idx = 4;

figure
plot(t,data.il)
legend(fsw_legend)
title(strcat('il ',dtype))
axis tight

NFFT = 2048;
ILF = fftshift(fft(data.il,2048,1));
f= linspace(-fs/2,fs/2, NFFT) / 1e3;
figure
plot(f, abs(ILF))
legend(fsw_legend)
xlabel('f (kHz)')
title(strcat('IL FFT ',dtype))
axis tight


