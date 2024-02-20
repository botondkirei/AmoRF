% AttributeClass - The template class for functionalities and
% non-idealities in RF/analog blocks.
%   
% AttributeClass properties:
%   SeqLen - Sequence Size. Deafault is 100000.
%
% AttributeClass methods:
%   effect - introduce the effect of the attribute
%   run - Break the input signal to SeqSize length sequencies and call
%   effect member for each chunk
%
% AttributeClass parents:
%   BaseClass - Superclass of amoRF toolbox.
%
% See also: BaseClass, SignalClass, BlockClass, TunerClass, GainClass,
% NoiseClass, FreqSelClass, FreqConvClass, PhaseNoiseClass, IQImbalClass.
% 

classdef AttributeClass < BaseClass
%% AttributeClass
%
% Parent classes: <BaseClass.html BaseClass>.
%
% A template class for RF/analog block attributes. The common methods of
% <BaseClass.html BaseClass> are inherited. The AttributeClass encapsulates
% the <AttributeClass.html#6 effect> method, that must be overwritten by
% the individual attribute implementation.
% 
%% Properties
%
% * <AttributeClass.html#7 SeqLen>
%
%% Inherited Properties 
% <BaseClass.html BaseClass>
%
% *  <BaseClass.html#3 Name> - Name of the object.
%
%% Methods
% * <AttributeClass.html#12 effect>
% * <AttributeClass.html#13 run>
%% Examples
% * <AttributeClass.html#8 Creating a user defined class for DC offset>.
    properties (Access=private)
        % Sequence length. Default value is 500000.
        SeqLen=500000
        %% SeqLen
        % The sequence length used by the  <AttributeClass.html#8 run>
        % method. DEfault value is 500000.
    end
    methods (Abstract)
        %% effect@AttributeClass
        %
        %  effect(OBJECT,INP)
        %
        % This abstract method is intended to be a templete for the functional
        % implementation of any attribute. |OBJECT| effectes the |INP|
        % signal (that is supposed to be an object of SignalClass) and
        % return the value in |OUTP|. 
        effect(obj,inp)
    end
    methods
        %% run@AttributeClass
        %
        %  OUTP=run(OBJECT, INP)
        %
        % Breaks the |INP| signal the SeqSize length chunks and invites the
        % <AttributeClass.html#7 effect> method of OBJECT on each chunk.
        % After processing the return values is assambled in |OUTP|. This
        % feature may be used when a long length signal is processed.
        function outp=run(obj, inp)
        % Run - Break the input signal to SeqSize length sequencies and call
        %   effect member for each chunk.
        %
        % OUTP=run(OBJECT, INP)
        %
        % Breaks the |INP| signal the SeqSize length chunks and invites the
        % AttributeClass/effect method of OBJECT on each chunk.
        % After processing the return values is assambled in OUTP. This
        % feature may be used when a long length signal is processed. 
            L=length(inp);
            N=floor(L/obj.SeqLen);
            copy=SignalClass([],1);
            outp=copy;
            for i = 1:N
                copy.samples=inp.samples(1:obj.SeqLen);
                inp.samples(1:obj.SeqLen)=[];
                copy=obj.effect(copy);
                outp.samples=[outp.samples copy.samples];
            end
            copy.samples=inp.samples;
            copy=obj.effect(copy);
            outp.samples=[copy.samples];
            outp.Fs=copy.Fs;
            outp.Fc=copy.Fc;
        end
        %% Creating a user defined class for DC offset 
        %
        % *Step 1.* The abstraction of DC offset
        %
        % The property of DC offset is a constant voltage that is added to the 
        % received baseband signal. Thus the class will encapsulate a property
        % called |offset| and the functionality that should be implemented is:
        % 
        % $$y(n)=x(n) + offset$$
        % 
        % where x(n) is the received baseband, and y(n) is the signal with 
        % DC offset.
        %
        % *Step 2.* Define DCOffsetClass and the abstract effect function
        %
        %  classdef DCOffsetClass < AttributeClass
        %    properties
        %      offset
        %    end
        %    methods
        %      function DCOffsetClass(obj,value)
        %        obj.offset=value;
        %      end
        %      function outp=effect(obj,inp)
        %        outp=inp+obj.offset;
        %      end
        %    end
        %  end
        %
        % DCOffsetClass is fully compatible with the amoRF toolbox.
    end
end