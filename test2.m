%test 2 -- test thermal noise
clear;
clc;
antenna = BlockClass('antenna');
antenna.Zout=50;
antenna.Znext=50;
tuner = TunerClass('rec');
tuner.add(antenna);
A=1e-3;
Fs=1e4;
sin=SignalClass(A*sin(2*pi*100*(0:1/Fs:10)),Fs);
rec = tuner.run(sin);
%power of the sin signal in dBm over the antenna impadance :
P=10*log10(sin.power(antenna.Zout + antenna.Znext)*1000);
%power of the noise floor for a bandwidth of Fs/2
%P_dbm = 10*log10(4*k*T*BW/1mW)
%P_dbm = 10*log10(k*T/1mW) + 10*log10(4*BW)
%P_dbm = -174 + 10*log10(4*BW)
N=-174 + 10*log10(4*Fs);
% SNR = P-N; the rec should have the same SNR
P-N
rec.SNR
