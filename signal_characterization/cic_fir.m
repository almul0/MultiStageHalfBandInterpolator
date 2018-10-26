%% CIC Filter

M=1; % Differential delay
Q=6; % Number of stages
RM = M*R;
g = (RM)^Q/R;
Dd = (RM-1)/2+1;
D = ceil(Q*Dd);

B = zeros(1, RM+1);
B(1)    = 1;
B(RM+1) = -1;
A       = [ 1 -1 ];

[h, t] = impz(B, A);     % Impulse response of single-stage CIC filter
hq = h;
if Q > 1
    for i=2:Q
        hq = conv(hq, h);
    end
end

data.int = data.dst;
il_R = kron(data.adc.il,[1 zeros(1,R-1)]');
il_R = il_R(1:size(data.int.il,1));
data.int.il = conv(il_R,hq)/g;
data.int.il = data.int.il(ceil(size(hq,1)/2)-ceil(D/2):end-floor(size(hq,1)/2)-ceil(D/2));
fprintf('#CIC interpolation Q=%d\n', Q)
interpolation_quality(data.dst, data.int, D, data.fsw, 1)

data.int.label = sprintf('CIC Q = %d ',Q);
interpolation_freq_spectra(data);
interpolation_signal_comparison(data);
