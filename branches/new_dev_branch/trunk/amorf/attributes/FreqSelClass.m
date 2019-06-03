% FreqSelClass - frequency selectivity attribute of RF/analog blocks
%
% FreqSelClass properties:
%   Flt - filter coeffitients
%
% FreqSelClass methods:
%   effect - Process an input signal
%
% FreqSelClass parents:
%   AttributeClass - functionalities and non-idealities
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, TunerClass, 
% GainClass, NoiseClass,  FreqConvClass, PhaseNoiseClass, IQImbalClass.
classdef FreqSelClass < AttributeClass
%% FreqSelectClass
% Parent class: <AttributeClass.html AttributeClass>.
% Frequency selectivity of RF/analog blocks.
%% Properties
% * <FreqSelClass.htnl#5 Flt>
% * <FreqSelClass.htnl#6 Init>
%% Methods
% * <FreqSelClass.html#8 constructor>
% * <FreqSelClass.html#9 effect>
    properties
        % Filter Coeffitients
        Flt
        %% Flt
        % This member is a concatenation of a filter nominator and
        % denominator. Best recommended to be used with MATLAB filter
        % design functions.
    end
    properties (Access=private)
        % Current state of the filter
        Init
        %% Init
        % This member stores the current state of the filter. The object
        % constructor initialize it to empty structure.
    end
    methods
        %% FreqSelClass@FreqSelClass
        %
        %  OBJ=FreqSelClass(NAME)
        %
        % Constructor of frequency selectivity attribute. The inherited
        % <BaseClass.html Name> property is set to |NAME| and the frequency 
        % selectivity object is returned in |OBJ|.
        %
        %  OBJ=FreqSelClass(NAME,FLT)
        %
        % Constructor of frequency selectivity attribute.  The inherited
        % <BaseClass.html Name> property is set to |NAME|, input |FLT|
        % is copied into the  <FreqSelClass.html#5 Flt> property and the 
        %  frequency selectivity object is returned in OBJ.
        function obj=FreqSelClass(name,flt)
        % FreqSelClass - Frequency selectivity attribute cosntructor
        %
        %	OBJ=FreqSelClass(NAME) - The inherited BaseClass/Name 
        %   property is set to NAME and the frequency selectivity object is 
        %   returned in OBJ.
        %
        %	OBJ=FreqSelClass(NAME, FLT) - The inherited BaseClass/Name 
        %   property is set to NAME, the input FLT is copied into the
        %   FreqSelClass/Flt property and the frequency selectivity object
        %   is returned in OBJ.
        % 
            obj.Name=name; % initializing the FreqSelClass/Name property
            switch nargin
                case 2
                    obj.Flt.a=flt.a;
                    obj.Flt.b=flt.b;
                    obj.Init=zeros(max(length(flt.a),length(flt.b))-1,1);
            end
        end
        %% effect@FreqSelClass
        %
        %  OUTP=effect(OBJECT,INP)
        %
        % The |INP| signal is recommended to be an object of
        % <SignalClass.html SignalClass>. The frequency selectivity is
        % implemented with:
        % 
        % $$ y(k)=x(k) * h(k)$$
        %
        % The return value |OUTP| is also
        % an object of <SignalClass.html SignalClass>. The 
        % method applies the frequency selectivity attribute.
        function outp=effect(obj,inp)
        %% effect
        %
        %	OUTP=effect(OBJECT,INP) - The INP signal is recommended to
        %	be an object of SignalClass. The return value OUTP is also an
        %	object of SignalClass. The method applies the frequency
        %	selectivity attribute. 
        %
        % See also: FreqSelClass/flt

            outp = SignalClass(inp);
            [outp.Samples,obj.Init] = filter(obj.Flt.b,obj.Flt.a,inp.Samples, obj.Init);
%            outp.Samples = filter(obj.Flt.b,obj.Flt.a,inp.Samples);
        end
    end
end