% TunerClass 
% Aggregate class of RF/analog blocks to create RF tuner
% composite models.
%
% TunerClass methods:
%   run - compute the response the an input signal
%
% TunerClass parents:
%   BlockClass - RF/analog block aggregate class.
%
% TunerClass properties (inherited from BlockClass)
%   Architecture - RF tuner architecture.
%   Signal -output signal of the RF tuner.
%   Zin - antenna impedance, default value 50 Ohm.
%   Zout - receiver output impedance, default value INF.
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, GainClass,
% NoiseClass, FreqSelClass, FreqConvClass, PhaseNoiseClass, IQImbalClass.
%
classdef TunerClass < BaseClass
%% TunerClass
% Parent class: <BlockClass.html BlockClass>.
% Aggregate class of RF/analog block to create behavioral RF tuner
% models.

%% Inherited Properties
% <BlockClass.html BlockClass>
%
% * *Architecture* - RF tuner/block architecture.
% * *Name* - name of the object.
%
%% Methods
% * <TunerClass.html#11 constructor>
% * <TunerClass.html#12 run>
% * <TunerClass.html#13 temp>
% * <TunerClass.html#14 nf>

%% Inherited methods
% <BaseClass.html BlockClass>
% * <BaseClass.html#15 add>
% * <BaseClass.html#16 getstructure>
% * <BaseClass.html#17 gain>
methods
        %% TunerClass@TunerClass
        %
        %  OBJ=TunerClass(NAME);
        %
        % Returns an object of TunerClass. NAME is written to TunerClass/Name
        % property. Zin, Zout and Signal are initialized to 50 Ohm, INF, and
        % SignalClass(0,0).
        %
        function obj=TunerClass(name)
        % TunerClass - Object constructor
        %
        %   OBJ=TunerClass(NAME) - NAME is written to TunerClass/Name
        %   property. Zin, Zout and TunerClass/Signal are initialized
        %   to 50 Ohm, INF, and SignalClass(0,0).
        %
        % See also: TunerClass/run, TunerClass/nf
        %

            obj.Name=name;

        end
        %% gain@TunerClass
        % 
        %  Gtotal=gain(OBJECT)
        %
        % Returns the equivalent gain of the RF tuner |OBJECT|. The
        % equivalent gain is computed with:
        %
        % $$ G_{total}=\prod\limits_i{G_i} $$
        %
        % <html>
        % where <i>G<sub>i</sub></i> are the
        % equivalent gains of the ith RF/analog block.
        % </html>
        
        function Gtotal=gain(obj)
        % GAIN Returns the equivalent gain of the RF tuner.
        %
        % Gtotal=gain(OBJECT) - Returns the equivalent gain of the RF
        % tuner OBJECT. 
        

            %get the voltage gain of the blocks respectivelly the input
            %and output impedences, to compute the available gain
            G=[];
            ZIN=[];
            ZOUT=[];
            blocks = fieldnames(obj.Architecture);
            [a,b] = size(blocks);
            for i=1:a
                componentname=char(blocks(i));
                G=[G obj.Architecture.(componentname).gain];
                ZIN=[ZIN obj.Architecture.(componentname).Zin];
                ZOUT=[ZOUT obj.Architecture.(componentname).Zout];
            end
            %voltage gain = Zload/(Zout + Zin)*voltage gain without load
            %set the last load to be infinite
            ZIN=[ZIN ZIN(end)];
            voltage_gain=ZIN(2:end)./(ZOUT+ZIN(2:end)).*G;
            power_gain=(ZIN(1:end-1)./ZIN(2:end)).*(G.^2);
            
            Gtotal=G(1);
            for i=2:length(G)
                Gtotal=Gtotal*G(i);
            end

        end
        %% EVM_IMG@TunerClass
        % 
        %  IMGs=EVM_IMG(OBJECT)
        %
        % Returns the equivalent error vector magnitude caused by the image suppression of the RF tuner |OBJECT|. The
        % equivalent error vector magnitude due to the image suppression is computed with:
        %
        % $$ EVM_{IMG}=\sqrt {{10}^{\frac{IMGs}{10}}} $$
        %
        % <html>
        % where <i>IMGs</i> is the
        % equivalent image supression of the mixer RF/analog block.
        % </html>
        
        function IMGs=EVM_IMG(obj)
        % EVM_IMG Returns the  error vector magnitude caused by equivalent image supression of the RF tuner.
        %
        % EVM_IMG=IMGs(OBJECT) Returns the equivalent  error vector magnitude caused by image suppression of the RF tuner
        % |OBJECT|.
        
            IMGs=obj.Architecture.MIX.imgs;
            IMGs=sqrt(10^(IMGs/10));

        end
        %% temp@TunerClass
        % 
        %  Ttotal=temp(OBJECT)
        %
        % Returns the equivalent temperature of the RF tuner |OBJECT|. The
        % equivalent temperature is computed with:
        %
        % $$ T_{total}=\sum\limits_i \frac{T_i}{\prod\limits_{i-1}{G_i}} , {G_0}=1  $$
        %
        % <html>
        % where <i>T<sub>i</sub></i> and <i>G<sub>i</sub></i> are the
        % equivalent temperatures and power gains of the ith RF/analog block.
        % </html>
        
        function Ttotal=temp(obj)
        % TEMP Returns the equivalent temperature of the RF tuner.
        %
        % Ttotal=temp(OBJECT) - Returns the equivalent temperature of the RF
        % tuner OBJECT. 
        

            %get the voltage gain of the blocks respectivelly the input
            %and output impedences, to compute the available gain
            G=[];
            ZIN=[];
            ZOUT=[];
            T=[];
            blocks = fieldnames(obj.Architecture);
            [a,b] = size(blocks);
            for i=1:a
                componentname=char(blocks(i));
                G=[G obj.Architecture.(componentname).gain];
                ZIN=[ZIN obj.Architecture.(componentname).Zin];
                ZOUT=[ZOUT obj.Architecture.(componentname).Zout];
                T=[T obj.Architecture.(componentname).temp];
            end
            %voltage gain = Zload/(Zout + Zin)*voltage gain without load
            %set the last load to be infinite
            ZIN=[ZIN ZIN(end)];
            voltage_gain=ZIN(2:end)./(ZOUT+ZIN(2:end)).*G;
            power_gain=(ZIN(1:end-1)./ZIN(2:end)).*(G.^2);
            
            Ttotal=T(1);
            Gtotal=power_gain(1);
            for i=2:length(T)
                Ttotal=Ttotal+T(i)/Gtotal;
                Gtotal=Gtotal*power_gain(i);
            end

        end
        %% cp1@TunerClass
        % 
        %  cp1total=CP1(OBJECT)
        %
        % Returns the equivalent 1dB compression point of the RF tuner |OBJECT|. The
        % equivalent 1dB compression point is computed with:
        %
        % $$ \frac{1}{CP1_{total}^2}=\sum\limits_i \frac{\prod\limits_{i}{G_{i-1}}}{{CP1_i}^2}, {G_0}=1 $$
        %
        % <html>
        % where <i>CP1<sub>i</sub></i> and <i>G<sub>i</sub></i> are the
        % equivalent compression points and gains of the ith RF/analog block.
        % </html>
        
        function CPtotal=cp1(obj)
        % cp1 Returns the equivalent 1dB compression point of the RF tuner.
        %
        % Cptotal=cp1(OBJECT) - Returns the equivalent 1dB compression point of the RF
        % tuner OBJECT. 
        

            %get the voltage gain of the blocks respectivelly the input
            %and output impedences, to compute the available gain
            G=[];
            ZIN=[];
            ZOUT=[];
            cp1=[];
            blocks = fieldnames(obj.Architecture);
            [a,b] = size(blocks);
            for i=1:a
                componentname=char(blocks(i));
                G=[G obj.Architecture.(componentname).gain];
                ZIN=[ZIN obj.Architecture.(componentname).Zin];
                ZOUT=[ZOUT obj.Architecture.(componentname).Zout];
                cp1=[cp1 obj.Architecture.(componentname).compoint];
            end
            %voltage gain = Zload/(Zout + Zin)*voltage gain without load
            %set the last load to be infinite
            ZIN=[ZIN ZIN(end)];
            voltage_gain=ZIN(2:end)./(ZOUT+ZIN(2:end)).*G;
            power_gain=(ZIN(1:end-1)./ZIN(2:end)).*(G.^2);
           
            CPtot=1/(cp1(1)^2);
            Gtot=(G(1)^2);
            for i=2:length(cp1)
                CPtot=CPtot+Gtot/(cp1(i)^2);
                Gtot=Gtot*(G(i)^2);
            end
            CPtotal=1/sqrt(CPtot);
            CPtotal=10*log10(CPtotal);
        end
        %% nf@TunerClass
        % 
        %  NF=nf(OBJECT)
        %
        % Returns the overall noise figure of the RF tuner. The noise
        % figure is computed from the equivalent temperature with the next
        % formula:
        %
        % $$ NF=10*log_{10}(T_{total}/290+1)$$
        %
        % <html>
        % where <i>T<sub>total</sub ></i> is the RF tuner equivalent
        % temperature.
        % </html>
        function noisefigure=nf(obj)
        % Returns the overall noise figure of the RF tuner. 
        % 
        %  NF=nf(OBJECT)
        %
        % Returns the overall noise figure of the RF tuner. 
            Ttotal=obj.temp;    
            noisefigure=10*log10(Ttotal/290+1);
        end        
        function output=cnr(obj,A,Fc,OverSamplingRatio)
            %CNR Carrier-to-noise ratio
            %
            %[cnr,obj]=CNR(obj,Fc,OverSamplingRatio)
            %
            %CNR(obj) Generates a carrier signal with A=-100dB amplitude, 
            %Fc=1e3 frequency at the sampling frequency Fs=Fc*1e3 and calls 
            %run(obj) to process the carrier. The return value is the
            %CNR measured in the received signal
            %
            %CNR(obj,A) Generates a carrier with the specified amplitude A,
            %Fc=1e3 frequency at the sampling frequency Fs=Fc*1e3 and calles 
            %run(obj) to receive the carrier. The return value is the
            %CNR measured in the received signal
            
            %% cnr
            %
            switch nargin
                case 1
                    A=10^(-100/20);
                    Fc=1e3;
                    OverSamplingRatio=1e3;
                case 2
                    A=10^(A/20);
                    Fc=1e3;
                    OverSamplingRatio=1e3;
                case 3
                    A=10^(A/20);
                    OverSamplingRatio=1e3;
                case 4
                     A=10^(A/20);
            end

            time=0:1/(Fc*OverSamplingRatio):10/Fc;
            carrier=SignalClass(A*exp(1i*2*pi*Fc*time),Fc*OverSamplingRatio);
            received=obj.run(carrier);
            %detect the carrier power (the peak in the signal spectrum
            %is considered the carrier)
            spectrum=abs(fft(received.Samples)/received.length);
            [m1,i1]=max(spectrum);
            %compute the overall power of the signal
            %noise=received - SignalClass(m1*sin(2*pi*Fc*time),Fc*OverSamplingRatio,0);
            m2=sum(spectrum(1:i1-OverSamplingRatio/2))+sum(spectrum(i1+OverSamplingRatio/2:end));
            %m3=noise.power;
            %CNR = carrier power / noise power
            %noise power is considered to be equal to overall signal power
            %- carrier power
            %CNR = carrier power / (signal power - carrier power)
            output=10*log10(m1/m2);
            %output=10*log10(m1/m3);
        end
    end
end