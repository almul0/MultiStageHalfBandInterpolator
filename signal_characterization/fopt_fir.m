%% FIR OPTIMO
clc
fpmin = 600e3;
% Especificaciones de frecuencia.
fp_factor = data.dst.fs/fpmin;
fs_factor = 0.2;

if (data.dst.fs/fp_factor > fpmin )
    fp=data.dst.fs/fp_factor; % Frecuencia de paso
else 
    fp=fpmin; % Frecuencia de paso
end
fs=fp+data.dst.fs*fs_factor; % Frecuencia de parada

nup = fp/data.dst.fs;
nus = fs/data.dst.fs;


fprintf('Diseño FIR Optimo\n')
fprintf('Frecuencia de paso: %.3f MHz Normalizada: %.4f\n',fp/1e6, nup)
fprintf('Frecuencia de parada: %.3f MHz Normalizada: %.4f\n',fs/1e6, nus)

ap = 0.001;
as = 20;

dp = (10^(ap/20) - 1)/(10^(ap/20) + 1);
ds = (1+dp)/10^(as/20);

[Mopt,nuopt,Aopt,Wopt]=firpmord([nup nus],[1 0],[dp ds]);
[bopt,Einf]=firpm(Mopt,nuopt,Aopt,Wopt);
while Einf>dp
    Mopt=Mopt+1;
    [bopt,Einf]=firpm(Mopt,nuopt,Aopt,Wopt);
end
freqz(bopt,1,1000,data.dst.fs)
fprintf('Orden del filtro: %d\n',Mopt)

data.int = data.dst;
il_R = kron(data.adc.il,[1 zeros(1,R-1)]');
il_R = il_R(1:size(data.int.il,1));

D = ceil(Mopt/2);
data.int.il = conv(il_R,R*bopt, 'same');
fprintf('#Fir Opt interpolation M=%d\n', Mopt)
interpolation_quality(data.dst, data.int, D, data.fsw, 1)

data.int.label = sprintf('FirOpt M = %d ',Mopt);
interpolation_freq_spectra(data);
interpolation_signal_comparison(data);