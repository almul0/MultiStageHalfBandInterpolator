%% FIR OPTIMO
clc

%M = 60;
fpmin = 0.6e6;
fsmin = 1.8e6;
% Especificaciones de frecuencia.
fp_factor = fpmin/data.dst.fs;

if (data.dst.fs*fp_factor > fpmin )
    fp=data.dst.fs*fp_factor; % Frecuencia de paso
else 
    fp=fpmin; % Frecuencia de paso
end

fs_factor = (fsmin-fp)/data.dst.fs;

fs=fp+data.dst.fs*fs_factor; % Frecuencia de parada

nup = fp/data.dst.fs;
nus = fs/data.dst.fs;

ap = 0.02;
as = 40;

fprintf('Diseño FIR Optimo\n')
fprintf('Frecuencia de paso: %.3f MHz Normalizada: %.4f\n',fp/1e6, nup)
fprintf('Frecuencia de parada: %.3f MHz Normalizada: %.4f\n',fs/1e6, nus)
fprintf('Ap: %.3f dB As: %.3f dB\n',ap, as)


dp = (10^(ap/20) - 1)/(10^(ap/20) + 1);
ds = (1+dp)/10^(as/20);


if (exist('M','var'))
    [bopt,Einf]=firpm(M,2*[0 nup nus 0.5],[1 1 0 0]);
    Mopt = M;
    clear M
else
    [Mopt,nuopt,Aopt,Wopt]=firpmord(2*[nup nus],[1 0],[dp ds]);
    [bopt,Einf]=firpm(Mopt,nuopt,Aopt,Wopt);
    while Einf>dp || mod(Mopt,2) ~= 0
        Mopt=Mopt+1;
        [bopt,Einf]=firpm(Mopt,nuopt,Aopt,Wopt);
    end
end
freqz(bopt,1,1000,data.dst.fs)
fprintf('Orden del filtro: %d\n',Mopt)

data.int = data.dst;
il_R = kron(data.adc.il,[1 zeros(1,R-1)]');
il_R = il_R(1:size(data.int.il,1));

D = ceil(Mopt/2);
data.int.il = conv(il_R,R*bopt, 'same');
fprintf('#Fir Opt interpolation M=%d (D=%d (%.3fns))\t (fp(MHz): %.3f, fs(MHz): %.3f, ap(dB): %.3f, as(dB): %.3f))\n', ...
        Mopt, D, D/data.int.fs*1e9, fp/1e6, fs/1e6, ap, as)
interpolation_quality(data.dst, data.int, D, data.fsw, 1)
fir_stats(bopt,R,[])


data.int.label = sprintf('FirOpt M = %d ',Mopt);
interpolation_freq_spectra(data);
interpolation_signal_comparison(data);