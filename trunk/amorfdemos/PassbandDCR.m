%[1] Citirea unui pachet OFDM 
    clear;
    load ofdm.mat; % contine 34 de pachete OFDM
    Signal = SignalClass(ofdm(1:end/34),1); % objectul FullOFDMFrameSignal 
    Signal.Fc=0;
    Signal.samples=Signal.samples*10^(30/20);

%[2] Incarcarea receptorului cu conversie directa
    REC=DCR;
    REC.Architecture{3}.Architecture{2}.Offset=REC.Architecture{3}.Architecture{2}.Offset +23e6;
    %pentru ca CFOClass a fost pregatit pentru simulare lowpass equivalent
    %simulation, pentru demodulare corecta in prezenta simulare este
    %necesar adunarea frecventei purtatoare a semnalului dorit.
%% [3] Receptia pachetului OFDM
    sout = REC.run(Signal);
%% [4] Afisari semnale
Signal.freq;
sout.freq;

l=sout.length;
faxes=((1:l)/l*sout.Fs)-(sout.Fs/2)+sout.Fc;
%H=freqz(b,a,faxes,sout.Fs);
            
figure(1); 
axes('FontSize',16); 
Signal.dB; grid on; 
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(2); 
axes('FontSize',16); 
REC.Architecture{2}.Signal.dB; grid on;
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(3); 
axes('FontSize',16); 
REC.Architecture{3}.Signal.dB; grid on;
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(4); 
axes('FontSize',16); 
REC.Architecture{4}.Signal.dB; grid on; hold on; %plot(faxes,db(abs(H)),'r');
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);
figure(5); 
axes('FontSize',16); 
REC.Architecture{5}.Signal.dB; grid on;
xlabel('Frequency (Hz)', 'fontsize', 16);
ylabel('Amplitude (dB)','fontsize',16);