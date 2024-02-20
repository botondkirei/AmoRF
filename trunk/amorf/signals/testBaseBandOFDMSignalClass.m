% testarea clasei BaseBandOFDMSignalClass
% 0. initializare
% 1. generarea semnalul OFDM cu doua metode diferite (prin insumarea
% subpurtatoarelor si prin transformarea IFFT)
% 2. cele doua semnale sunt comparate in domeniul timp
% 3. un semnal este demodulat si simbolurile deupa demodulare sunt
% comparate cu semnalul modulator

%% 0. Crearea unui mesaj aleator
clear;
M = 16;                     % Alphabet size
x = randi([0 M-1],1705,1);  % Random symbols

% Maparea 16-QAM
hMod = modem.qammod(M);
hDemod = modem.qamdemod(hMod);

% mapare
y = modulate(hMod,x);

%% 1.1. generarea simbolului OFDM
ofdm1=BaseBandOFDMClass;
ofdm1.implementation='sum';
signal1=ofdm1.process(y);


%% 1.2. generarea simbolului OFDM
ofdm2=BaseBandOFDMClass;
ofdm2.implementation='transform';
signal2=ofdm2.process(y);


%% 2. Comparatia semnalului OFDM
figure(1);
signal1.domain='freq';
signal1.plot;
figure(2);
signal2.domain='freq';
signal2.plot;

%% 3. Demodularea simbolului OFDM
ofdm3=BaseBandOFDMClass;
ofdm3.modem='dem';
yrec=ofdm3.process(signal2);
% demapare
z = demodulate(hDemod,yrec); 
ber=biterr(x,z');
disp(['BER = ' num2str(ber)]);
