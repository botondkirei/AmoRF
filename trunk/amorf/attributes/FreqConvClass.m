% FreqConvClass - Frequency conversion attribute
%
% FreqConvClass properties:
%   offset - Carrier frequncy / Carrier frequency offset
%   T0 - Initial time. Initial value is 0.
%
% FreqConvClass methods:
%   effect - Process an input signal
%   multiplier - Computes the carrier signal
%
% FreqConvClass parents:
%   AttributeClass - functionalities and non-idealities
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, TunerClass, 
% GainClass, NoiseClass,  FreqSelClass, PhaseNoiseClass, IQImbalClass.


classdef FreqConvClass < AttributeClass
%% FreqConvClass
% Parent class: <AttributeClass.html AttributeClass>.
% FreqConvClass has double purpose. The first one is to achieve downconversion
% when a passband simulation is running. The second one is to model Carrier
% Frequency Offset (CFO) in the receiver.

%% Properties
% * <#5 Offset>
% * <#6 T0>

%% Methods
% * <FreqConvClass.html#8 FreqConvClass>
% * <FreqConvClass.html#9 effect>
% * <FreqConvClass.html#10 multiplier>    
    properties
        % Carrier frequency / Carrier frequency offset
        Offset
        %% Offset
        % Carrier frequency / Carrier frequency offset
    end
    properties (Access=private)
        % Initial time. Initial value is 0.
        T0
        %% T0 - StartTime
        % Initial time. Property used by the effect cmember, to start
        % generation of the carrier with at T0. When the input sequency is
        % split to frames the effect member will generate a carrier signal
        % for each frame. The carrier of frame number N+1 will be continued
        % where the carrier of N was finished. Initial value is 0.
    end
    methods
        %% FreqConvClass@FreqConvClass
        %
        %  OBJ=FreqConvClass(NAME)
        %
        % FreqConvClass object contructor. The FreqConvClass/Name property
        % is set to |NAME|.
        function obj=FreqConvClass(name)
        % FreqConvClass object constructor.
        %
        %   OBJ=FreqConvClass(NAME) - The FreqConvClass/Name property
        %   is set to NAME.
            obj.Name=name;
            obj.T0=0;
        end
        %% effect@FreqConvClass
        %
        %  OUTP=effect(OBJECT,INP)
        %
        % Applies the |OBJECT| frequency conversion to input signal |INP| 
        % and returns th result in |OUTP| using formula:
        %
        % $$ y(k)=x(k) \cdot e^{multiplier(k)}$$
        %
        % where _multiplier(k)_ is computed by <FReqConvClass.html#9
        % multiplier> method.
        function outp=effect(obj,inp)
        % PROCESS - Applies the frequency conversion.
        %
        %	OUTP=effect(OBJECT,INP) Applies the OBJECT frequency
        %	conversion to input signal INP and returns th result in OUTP
        %	using formula:
        %
        %   y(k)=x(k)*exp(multiplier(k))
        %
        %   where multiplier(k) is a signal computed with
        %   FreqConvClass/multiplier method.
        % 
        % See also: FreqConvClass/multiplier.
            m=obj.multiplier(inp);
            outp=inp.*m;
        end
        function test(obj)
            M = 16;                     % Alphabet size
            x = randi([0 M-1],1705,1);  % Random symbols

            % Maparea 16-QAM
            hMod = modem.qammod(M);

            % mapare
            y = modulate(hMod,x);
            ofdm=BaseBandOFDMClass;
            ofdm.implementation='sum';
            signal=ofdm.effect(y);
            signal.flip;
            signal.domain='freq';
            signal.plot;
            
            % cfo
            obj.offset=1e6;
            signal = obj.effect(signal);
            
            figure;
            signal.plot;
        end
    end
    methods (Access=private)
        %% multiplier@FreqConvClass
        %
        %  OUTP=multiplier(OBJECT,INP)
        %
        % Computes _multiplier(k)_ signal used by <FreqConvClass.html#8
        % effect>.
        function outp=multiplier(obj,inp)
        % Multiplier - Returns the carrier signal.
        %
        %	OUTP=multiplier(OBJECT,INP) Computes multiplier(k) signal 
        %	used by FreqConvClass/effect.
        %
        % See also: FreqConvClass/effect.
            
            l=length(inp.Samples);
            Fs=inp.Fs;
            T=(1:l)/Fs;
            outp=SignalClass(exp(-1i*2*pi*(obj.Offset)*(T+obj.T0)),Fs);
            obj.T0=obj.T0+l/Fs;
        end 
    end
end