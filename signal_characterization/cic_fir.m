%% CIC Filter
M=1; % Differential delay
Q=12; % Number of stages
RM = M*R;
gcic = (RM)^Q/R;
Dd = (RM-1)/2+1;
D = ceil(Q*Dd);

B = zeros(1, RM+1);
B(1)    = 1;
B(RM+1) = -1;
A       = [ 1 -1 ];

% BQ = B;
% AQ = A;
% if Q > 1
%     for i=2:Q
%         BQ = conv(BQ, B);
%         AQ = conv(AQ, A);
%     end
% end
% hcic = impz(BQ,AQ)';

b = impz(B,A)';
hcic = b;
if Q > 1
    for i=2:Q
        hcic = conv(hcic, b);
    end
end
hcic = hcic(find(hcic==max(hcic))-D/2:find(hcic==max(hcic))+D/2);

plot(hcic)

Fc = 0.8e6;
%%%%%%% fir2.m parameters %%%%%%
L = 60; %% Filter order; must be even
Fo = Fc/data.adc.fs; %% Normalized Cutoff freq; 0<Fo<=0.5/M;
% Fo = 0.5/M; %% use Fo=0.5 if you don't care responses are

%%%%%%% CIC Compensator Design using fir2.m %%%%%%
p = 2e3; %% Granularity
s = 0.25/p; %% Step size
fp = [0:s:Fo]; %% Pass band frequency samples
fs = (Fo+s):s:0.5; %% Stop band frequency samples
f = [fp fs]*2; %% Normalized frequency samples; 0<=f<=1
Mp = ones(1,length(fp)); %% Pass band response; Mp(1)=1
Mp(2:end) = abs( M*R*sin(pi*fp(2:end)/R)./sin(pi*M*fp(2:end))).^Q;
Mf = [Mp zeros(1,length(fs))];
f(end) = 1;
hcomp = fir2(L,f,Mf); %% Filter length L+1
%hcomp = hcomp/max(hcomp);

[HCIC,fcic]=freqz(hcic,1,1000,data.dst.fs);
[HCOMP,fcomp]=freqz(hcomp,1,1000,data.adc.fs);
figure
hold on
plot(fcic,20*log10(abs(HCIC)/max(abs(HCIC))))
plot(fcomp,20*log10(abs(HCOMP)))
xlabel('\omega/\pi')
ylabel('Gain, dB')
grid

data.int = data.dst;
data.int.il = conv(data.adc.il,hcomp,'same');
il_R = kron(data.int.il,[1 zeros(1,R-1)]');
il_R = il_R(1:size(data.dst.il,1));
data.int.il = conv(il_R,hcic,'same')/gcic;

% data.int.il = conv(data.int.il,hcomp,'same');
size(data.int.il)



fprintf('#CIC interpolation Q=%d\n', Q)
interpolation_quality(data.dst, data.int, D, data.fsw, 1)

data.int.label = sprintf('CIC Q = %d ',Q);
interpolation_freq_spectra(data);
interpolation_signal_comparison(data);
