%% Lagrange filtering

n = 1:2:13;
int_results = zeros(size(n,2),5);

data.int = data.dst;
il_R = kron(data.adc.il,[1 zeros(1,R-1)]');
il_R = il_R(1:size(data.int.il,1));

for i=1:length(n)
    
    h = intfilt(R,n(i),'Lagrange'); % Si L y n par fase no lineal
    
%     figure(fig_freqz)
%     [h_imp,w] = freqz(h,1,[]);
%     plot(w/pi,10*log(abs(h_imp)),'DisplayName',sprintf('Q = %d ',n(i)+1))
%     title('Lagrange filter')
    
    D = ceil(((n(i)+1)*R-1)/2);
    data.int.il = conv(il_R,h, 'same');
    fprintf('#Lagrange interpolation Q=%d\n', n(i)+1)
    interpolation_quality(data.dst, data.int, D, data.fsw, 1)

%    pause
end

data.int.label = sprintf('Lagrange M = %d ', n(i)+1);
interpolation_freq_spectra(data);
interpolation_signal_comparison(data);