clear;
M = 16;                     % Alphabet size
x = randi([0 M-1],1705,1);  % Random symbols

% Maparea 16-QAM
hMod = modem.qammod(M);
hDemod = modem.qamdemod(hMod);

% mapare
y = modulate(hMod,x);

%% 1.1. generarea simbolului OFDM
ofdm=BaseBandOFDMClass;
ofdm.implementation='sum';
signal=ofdm.run(y);
signal.Fc=1.7e9;
%signal.Data=signal.Data;
%signal.flip;
 
% %add noise caused by the antenna
T=300; %room temperature
B=8e6; %TDMB channel bandwidth
noisePower = T*B*NoiseClass.k;
%signal.SNR = 10*log10(signal.power/noisePower);

%% 1.2. generarea receptorului si rularea receptorului
REC=DCR('DCR');
%% 
REC.run(signal);

%% 1.3. afisarea semnalelor
signal.freq;
REC.Signal.freq;

l=REC.Signal.length;
faxes=((1:l)/l*REC.Signal.Fs)-(REC.Signal.Fs/2)+REC.Signal.Fc;
load lowpassfilter.mat;
H=freqz(b,a,faxes,REC.Signal.Fs);
            
figure(1); 
axes('FontSize',16); 
signal.dB; grid on; 
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(2); 
axes('FontSize',16); 
REC.Architecture{1}.Signal.dB; grid on;
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(3); 
axes('FontSize',16); 
REC.Architecture{2}.Signal.dB; grid on;
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(4); 
axes('FontSize',16); 
REC.Architecture{3}.Signal.dB; grid on; hold on; plot(faxes,db(abs(H)),'r');
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(5); 
axes('FontSize',16); 
REC.Architecture{4}.Signal.dB; grid on;
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
