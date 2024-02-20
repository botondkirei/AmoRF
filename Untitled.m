%test 1 -- RF block connection test
clear;
antenna = BlockClass('antenna');
antenna.Zout=50;
antenna.Znext=50;
adc=BlockClass('adc');
adc.Zout = 1;
adc.Znext = 100;
tuner = TunerClass('rec');
tuner.add(antenna);
tuner.add(adc);
sin=SignalClass(1e-6*sin(2*pi*100*(0:1e-3:10)),1/.0005);
rec = tuner.run(sin);
rec.dBm(1)