function interpolation_freq_spectra(data)
    
    figure;
    NFFT = 2^16;
    f= linspace(-data.adc.fs/2,data.adc.fs/2, NFFT) / 1e3;
    f_osc= linspace(-data.osc.fs/2,data.osc.fs/2, NFFT) / 1e3;
    f_dst = linspace(-data.dst.fs/2,data.dst.fs/2, NFFT) / 1e3;
    IL_F = fftshift(fft(data.adc.il,NFFT));
    ILOSC_F = fftshift(fft(data.osc.il,NFFT));
    ILD_F = fftshift(fft(data.dst.il,NFFT));
    plot(f_osc, 10*log10(abs(ILOSC_F)/max(abs(ILOSC_F))), 'k', 'DisplayName', data.osc.label)
    hold on
    plot(f_dst, 10*log10(abs(ILD_F)/max(abs(ILD_F))), ':b', 'LineWidth',2, 'DisplayName', data.dst.label)
    plot(f, 10*log10(abs(IL_F)/max(abs(IL_F))),'g','DisplayName', data.adc.label)
    if isfield(data,'int') 
       f_int =  linspace(-data.int.fs/2,data.int.fs/2, NFFT) / 1e3;
       IL_INT = fftshift(fft(data.int.il,NFFT));
       plot(f_int, 10*log10(abs(IL_INT)/max(abs(IL_INT))),'r','DisplayName', data.int.label)
    end
    xlabel('f (kHz)');
    title(strcat('IL FFT ',data.dtype));
    axis tight
    xlim([-data.int.fs/2 data.int.fs/2]/1e3)
    legend;
end

