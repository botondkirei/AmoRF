%generates the baseband OFDM signal (without frequency upconversion)
classdef BaseBandOFDMClass < BaseClass
    properties
        Tu=224e-6; %data duration
        delta=56e-6; %guard interval
        %delta=0; %no guard interval inserted
        Kmin=0;
        Kmax=1704;
        implementation='transform' 
        %generarea semnalului OFDM este facilitat cu doua metode diferite;
        %prima metoda sumeaza purtatoarele modulate de simbolurile
        %complexe; a doua metoda utilizeaza un bloc IFFT pentru generarea
        %semnalului in urma caruie sa efectuaza si adaugarea intervalului
        %de garda; metoda utilizata se va selecta prin proprietatea 
        %'implementation'; valorile posibile 'sum' pentru prima metoda, iar
        %'transform' pentru a doua metoda
         modem='mod'
        % obiectele pentru modulare si demodulare vor fi derivate din clasa
        % curenta; proprietatea selectoare este 'modem'; pentru modulare se
        % seteaza 'mod', pentru demodulare se seteaza 'dem'; prefixul
        % ciclic este taiat si demodularea este realizata cu ff; obiectul
        % setat pe 'dem' nu ia in cosiderare valoarea proprietatii 'implementation'
        N=2048 %IFFT/FFT size
        %numarul de puncte a IFFT/FFT-ului
    end
    methods
        function output=effect(obj,input)
            switch upper(obj.modem)
                case 'MOD'
                    switch upper(obj.implementation)
                        case 'SUM'
                            output=obj.sum(input);
                        case 'TRANSFORM'
                            output=obj.transform(input);
                    end
                case 'DEM'
                    output = obj.demod(input);
            end
        end
    end
    methods (Access=private)
        function output= sum(obj,symbols)
            % functia sum este folosit pentru comparatia semnalului ideal,
            % descrisa in standard cu semnalul generat cu transormarea IFFT
            % in urma simularilor am observat ca datorita unui efect
            % asemanator la 'aliasing' semnalul generat cu functia sum este
            % distorsionat in domeniul timp, rezultand in diferente
            % semnificative fata de semnalul generat prin trans. IFFT
            % functia era implementat pentru a folosi ca un instrument de
            % autoverificare/test
            OvrSmp=4;
            T=obj.Tu/obj.N/2/OvrSmp; %elementary period
            t=-obj.delta+T:T:obj.Tu; %time axis
            s=zeros(size(t));
            for k=obj.Kmin:obj.Kmax
                kp=k-(obj.Kmin+obj.Kmax)/2;
                s=s+symbols(k+1)*exp(1i*2*pi*kp*(t-obj.delta)/obj.Tu);
            end
            s=s/obj.N/OvrSmp;
            %output=SignalClass(s,length(s)/(obj.Tu+obj.delta));
            output=SignalClass(s,1/T);
        end
        function output= transform(obj,symbols)
            Fs=obj.N/obj.Tu;
            prefix_size  = Fs*obj.delta;

            DC           = (obj.Kmax)/2 + 1; %'componenta' la curent continuu
            % ---- rearanjarea simbolurilor pentru ifft
             z                             = zeros(1,obj.N);
             z(1:DC)                     = symbols(DC:obj.Kmax+1);
             z(length(z)-DC+2:length(z)) = symbols(1:DC-1);

            % ---- ifft
            carriers = ifft(z);
            % ---- prefix
            prefix               = carriers((obj.N-prefix_size+1:obj.N));
            %adaugarea prefixului
            s                    = [prefix carriers];
            %generarea semnalului de iesire
            output=SignalClass(s,length(s)/(obj.Tu+obj.delta));
        end
        function output=demod(obj,input)
            % signal 'input' is supposed to be an object of the SignalClass
            % ----- remove cyclic prefix
            % compute the number of samples used by the cyclic prefix
            Fs=obj.N/obj.Tu;
            prefix_size  = Fs*obj.delta;
            % remove prefix
            ofdm_symbol=input.Samples(prefix_size+1:end);
            % ----- fourier transform
            carrier=fft(ofdm_symbol);
            % ----- jumate din purtatori
            DC           = (obj.Kmax)/2 + 1; 
            % ----- rearanjarea simbolurilor
            output = zeros(1,obj.Kmax+1);
            output(DC:obj.Kmax+1) = carrier(1:DC);
            output(1:DC-1) = carrier(end-DC+2:end);
        end
    end
    methods (Static)
        function selftest()
            
            %[1] Initialize parameters
            %[2] BER 
            %[2.1] Generate random symbols
            %[2.2] OFDM modulation
            %[2.3] AWGN Channel
            %[2.4] OFDM demodulation
            %[5] plot BER 
            
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

        end
    end
end