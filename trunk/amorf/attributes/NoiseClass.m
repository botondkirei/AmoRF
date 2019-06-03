% NoiseClass - Noise in RF/analog blocks
%
% NoiseClass properties:
%   k - The Boltzmann constant k=1.38*1e-23 Joule/Kelvin.
%	Te - equivalent temperature of the RF/analog block
%   R - resistance
%   B - noise bandwidth
%
% NoiseClass methods:
%   effect - effect an input signal
%   nf - get noise figure of RF/analog block
%   gain - get voltage gain (without load) of RF/analog block
%   temp - get equvalent temperature of RF/analog block
%
% NoiseClass parents:
%   AttributeClass - functionalities and non-idealities of an RF/analog block.
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, TunerClass, 
% GainClass, FreqSelClass, FreqConvClass, PhaseNoiseClass, IQImbalClass.


classdef NoiseClass < AttributeClass
%% NoiseClass
% Parent class: <AttributeClass.html AttributeClass>.
% Noise in RF/analog blocks.
%% Properties
% * <NoiseClass.html#6 k - constant>
% * <NoiseClass.html#8 Te>
% * <NoiseClass.html#9 R>
% * <NoiseClass.html#10 B>
%% Inherited Properties
% <BaseClass.html BaseClass>
%
% * <BaseClass.html#3 Name> - Object name
%
% <AttributeClass.html AttributeClass>
%
% * <AttributeClass.html#9 AggObj> - Aggregate object handler
%
%% Methods
% * <NoiseClass.html#14 NoiseClass>
% * <NoiseClass.html#15 write>
% * <NoiseClass.html#16 nf>
% * <NoiseClass.html#17 effect>

    properties (Constant)
        % Boltzmann constant: 1.38*10e-23  Joule/Kelvin
        k=1.38*1e-23 
        %% k
        % Boltzmann constant: 1.38*10e-23 Joule/Kelvin.
    end
    properties
        % Temperature in Kelvin
        T=290 
        %% Te
        % Equivalent RF component temperaturein Kelvin. Default value is
        % 290 K.
        
        % Resistance in Ohm, default value 50 Ohm.
        R=50 
        %% R
        % Resistor impedance. Default value 50 Ohm.
        
        % Equivalent noise bandwidth
        B=1
        %% B
        % The bandwidth of the useful signal in the modeled RF/analog
        % block.
    end
    methods
        %% NoiseClass@NoiseClass
        %
        %  OBJ=NoiseClass(NAME)
        %
        % NoiseClass object contructor. The NoiseClass/Name property
        % is set to |NAME|.
        function obj=NoiseClass(name)
        % NoiseClass object constructor.
        %
        %   OBJ=NoiseClass(NAME) - The NoiseClass/Name property
        %   is set to NAME.
        obj.Name = name;
        end
        %% write@NoiseClass
        %
        %  OBJ=write(OBJECT,'NF',VALUE)
        %
        % A convenient way to model the amount of noise introduced by an RF
        % component is the noise figure (NF). If NF is specified instead of 
        % equivalent temperature, then the value of property  
        % <NoiseClass.html#8 Te> is computed from NF with the next relation: 
        % 
        % $$ Te=290*(10^{NF/10} - 1).$$
        %
        %  OBJ=write(OBJECT,'TEMP',VALUE)
        %
        % The input VALUE is written to property *Te*.        
        function obj=write(obj,property,value)
        % WRITE Write a property of the object
        %
        %	OBJ=write(OBJECT,'NF',VALUE) A convenient way to model the 
        %   amount of noise introduced by an RF/analog block is the noise 
        %   figure (NF). If NF is specified instead of equivalent 
        %   temperature, then the value of property NoiseClass/Te is
        %   computed from NF with the relation Te=290*(10^(NF/10) - 1).
        %
        %   OBJ=write(OBJECT,'TEMP',VALUE) The input VALUE is written to 
        %   property NoiseClass/Te.       
        %
        % See also: NoiseClass/nf, NoiseClass/effect
            switch upper(property)
                case 'TEMP'
                    obj.Te=value;
                case 'NF'
                    obj.Te = 290 * (10^(value/10)-1);
                otherwise
                    obj.(property)=value;
            end
        end
        %% nf@NoiseClass
        %
        %  NF=nf(OBJECT)
        %
        % Return the noise figure of the RF/analog block.
        function NF=nf(obj)
        % NF - Return the noise figure of the RF/analog block.
        %
        %  NF=nf(OBJECT)
            NF=10*log10(obj.Te/290+1);
        end
        %% effect@NoiseClass
        %
        % <html>
        % The added noise power in the i<sup>th</sup> RF/analog block
        % in the tuner is:
        % </html>
        % 
        % $$ \Delta N_i  = G_p \cdot N_{in} \cdot (nf - 1)$$
        %
        % <html>
        % where <i>G<sub>p</sub></i>, <i>N<sub>in</sub></i>, and <i>nf</i>
        % are the power gain, the input noise power and the noise factor
        % (the linear value of the noise figure). 
        % </html>
        %
        % The implementation of thermal noise effect in the input signal.
        %
        % $$ y(k)=x(k)+ \Delta N_i*n(k) $$
        %
        % where _x_, _y_, _n_ are input, output respectivelly unit variance
        % normally distibuted random signal.
        %
        %  OUTP=effect(OBJECT,INP)
        %
        % The noise is added to signal |INP| and returned in signal |OUTP|.
        function outp=effect(obj,inp)
        % PROCESS - add the effect of noise to an input Signal
        %
        % The added noise power in the i-th RF/analog block in the tuner is:
        % 
        % dNi = Gp * Nin * (nf - 1)
        %
        % where Gp, Nin, and nf are the the power gain, the noise power at
        % the input and the noise factor (the linear value of the noise
        % figure).
        %
        % The implementation of thermal noise effect in the input signal.
        %
        % y(k)=x(k)+dNi*n(k)
        %
        % where x, y, n are input, output respectivelly unit variance
        % normally distibuted random signal.
            outp=inp;
            l=outp.length;
            outp = outp.addNoise(obj.getNoise(l));
        end
        function outp = noise_power(obj)
             outp = 4*obj.k*obj.T*obj.B;
        end
        function outp = getNoise(obj, size)
            noise_power = 10*log10(obj.noise_power); % in dBW
            outp = wgn(1,size,noise_power, obj.R);
        end
        %% DEMO - Modeling the thermal noise of an antenna
        % 
        function demo1(~)
            %construct an noise object
            o=NoiseClass('Noise'); %in loc de o=NoiseClass;
            %model the thermal noise floor for 1 Hz bandwith at room
            %temperature
            o=o.write('B',1); % 1Hz Bandwidth
            o=o.write('R',1); % 1 Ohm resistance
            % generate a sinusoid at 1Hz with the average power of -140 dBm
            R=1;Tsample=0.01;
            Pavg=10^(-140/10)/1000; % convert from dmb to linear value
            A=sqrt(Pavg/R/2);
            s=SignalClass(A*sin(2*pi*(0:Tsample:10)),1/Tsample);
            subplot(2,1,1);
            s.dBm(R); % plot the spectrum of the signal
            s2=o.run(s); % add thermal noise to the signal
            subplot(2,1,2);
            s2.dBm(R); % plot the spectrum of the signal + noise
        end
            
    end
end
% Thermal noise is a common impediment in every RF component, thus this is
% the choose for the example. First an object of the
% <../amorf/nonidealities/html/NoiseClass.html NoiseClass> is 
% instantiated, next the important properties are initialized and finally a
% signal (contained in a <../amorf/generic/html/SignalClass.html
% SignalClass> object) is effected. 

%thermal=NoiseClass; % object instatiation
%thermal.Te = 290; % the noise temperature
%thermal.B = 1; % noise bandwidth
%thermal.R = 50; % the impedance (in Ohm) on which the termal noise exercise its effect 
%signal=SignalClass(zeros(1000,1),1); % NoiseClass effectes only SignalClass objects
%signal=thermal.effect(signal); % the effect of thermal noise on the signal
%signal.power(50); % measure the power of the noise on a 50 Ohm impedance