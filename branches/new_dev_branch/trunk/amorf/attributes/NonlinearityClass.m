% NonlinearityClass - Gain and non-linearity attribute of RF/analog block.
%
% NonlinearityClass properties:
%   A1 - First order component voltage gain (without load)
%   A3 - Third order component gain
%   Aisat - Input referred saturation voltage 
%   Aosat - Output reffered saturation voltage
%   CP1 - 1dB compression point
%
% NonlinearityClass methods:
%   NonlinearityClass - Object constructor
%   set.A1 - Method invited on the A1 access
%   set.A3 - Method invited on the A3 access
%   effect - Process an input signal
%   update - Update Aisat and Aosat
%
% NonlinearityClass parents:
%   AttributeClass - functionalities and non-idealities
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, TunerClass, 
% NoiseClass, FreqSelClass, FreqConvClass, PhaseNoiseClass, IQImbalClass.
classdef NonlinearityClass < AttributeClass
%% NonlinearityClass
% Parent class: <AttributeClass.html AttributeClass>.
% Gain and non-linearity attribute of RF/analog block. 
%% Properties
% * <NonlinearityClass.html#5 A1>
% * <NonlinearityClass.html#6 A3>
% * <NonlinearityClass.html#7 Aisat>
% * <NonlinearityClass.html#8 Aosat>
% * <NonlinearityClass.html#9 CP1>
%% Inherited Properties
% <BaseClass.html BaseClass>
% * <BaseClass.html#3 Name> - Object name
%% Methods
% * <NonlinearityClass.html#11 constructor>
% * <NonlinearityClass.html#12 set.A1>
% * <NonlinearityClass.html#13 set.A3>
% * <NonlinearityClass.html#14 effect>
% * <NonlinearityClass.html#15 update>
%
    properties
        % First order component voltage gain (without load). Default value
        % 1 (0 dB gain). 
        A1=1 
        %% A1
        % Voltage gain of the first order therm (in linear metrics). Default
        % value is |1|. When gain is specified in dB then set the value
        % of <NonlinearityClass.html#5 A1> to:
        %
        % $$ A_{1}=10^{gain/20}. $$
        %
        % When power gain is specified (in dBm) then set <NonlinearityClass.html#5 A1> to:
        %
        % $$ A_{1}=10^{P_{gain}/10}. $$

        % Third order component gain. Default value 0.
        A3=0 
        %% A3
        % Voltage gain of the third order therm (in linear metrics). Default
        % value is |0|.
        
        % Input referred saturation voltage 
        Aisat 
        %% Aisat
        % Maximum voltage at the RF/analog block input.
        
        % Output reffered saturation voltage
        Aosat 
        %% A0sat
        % Maximum voltage at the RF/analog block output.
        CP1
        %% CP1
        % 1dB compression point
  
    end
    methods
        %% NonlinearityClass@NonlinearityClass
        %
        %  OBJ=NonlinearityClass(NAME);
        %
        % The NonlinearityClass object constructor. The constructor calls for the 
        % <NonlinearityClass.html# update> member of the class that computes the values
        % of <NonlinearityClass.html# Aisat> and <NonlinearityClass.html# Aosat>.
        %
        %  OBJ=NonlinearityClass(NAME,A1,CP1)
        %
        % An common way to model the gain and non-linearity of an RF/analog
        % block is the voltage gain A1 (in dB) and the 1dB compression point CP1 (in dBm).
        % The 1dB compression point is situated in interception of the
        % input vs. output gain characteristics looses 1dB amplification
        % with respect to it's ideal value. The 1dB compression point is
        % approximatly 10dB lower than the IIP3 (the third order intercept
        % point). When A1 and CP1 is used to instantiate the NonlinearityClass the 
        % A3 si computed with:
        %
        % $$ A_3 = 0.1087 \frac{A_1}{\sqrt{\frac{2R}{1000} 10^{CP_1/10}}} $$
        %
        % where R=1 Ohm. For the following syntax the R can be transmitted
        % to the constructor:
        %
        %  OBJ=NonlinearityClass(NAME,A1,CP1,R)
        %        
        function obj=NonlinearityClass(name,A1,CP1,R)
            % NonlinearityClass - Object constructor.
            %
            %   OBJ=NonlinearityClass(NAME) - Sets the NonlinearityClass/Name property to
            %   NAME and calls for the NonlinearityClass/update member of the class.
            %   
            %   OBJ=NonlinearityClass(NAME,A1,CP1) - An common way to model the
            %   gain and non-linearity of an RF/analog block is the voltage
            %   gain A1 and the 1dB compression point CP1. The 1dB
            %   compression point is situated in interception of the input
            %   vs. output gain characteristics looses 1dB amplification
            %   with respect to it's ideal value. The 1dB compression point
            %   is approximatly 10dB lower than the IIP3 (the third order
            %   intercept point). When A1 and CP1 is used to instantiate the
            %   NonlinearityClass the A3 si computed with:
            %
            %      A3 = 0.1087*A1/sqrt(2*R/1000*10^(CP1/100)
            %
            %   where R=1 Ohm. For the following syntax the R can be
            %   transmitted to the constructor:
            %
            %   OBJ=NonlinearityClass(NAME,A1,CP1,R)
            %
            % See also: NonlinearityClass/set.A1, NonlinearityClass/set.A3,
            %  NonlinearityClass/effect, NonlinearityClass/update.
            %
            
            %computation Aisat si Aosat property in function of A1 and A3
            switch nargin
                case 1
                    obj.Name = name;
                case 3
                    obj.A1=10^(A1/20);
                    obj.A3=0.1087*obj.A1/sqrt(2/1000*10^(CP1/10));
                case 4
                    obj.A1=10^(A1/20);
                    obj.A3=0.1087*obj.A1/sqrt(2*R/1000*10^(CP1/10));
            end
            update(obj);
            %obj.CP1=10^(CP1/10)
        end
        %% set.A1@NonlinearityClass
        %
        %  OBJ=set.A1(OBJECT,VALUE)
        %
        % Method invited when <NonlinearityClass.html#5 A1> is accessed for
        % writing. The member invites <NonlinearityClass.html#15 update> to compute
        % the values of <NonlinearityClass.html# Aisat> and <NonlinearityClass.html#
        % Aosat>. |VALUE| is considered to be in the linear scale.
        function obj=set.A1(obj,val)
        % SET.A1 - Method invited when NonlinearityClass/A1 property is acessed for
        % writing 
        %
        %   OBJ=set.A1(OBJECT,VALUE) -  Method invited when
        %   NonlinearityClass.html/A1 is accessed for writing. The member
        %   writes VALUE into the A1 filed of OBJECT, then 
        %   invites NonlinearityClass/update to compute the values of 
        %   NonlinearityClass/Aisat and NonlinearityClass/Aosat. VALUE is considered to be
        %   in the linear scale.
        %
        % See also: NonlinearityClass/NonlinearityClass, NonlinearityClass/set.A3, 
        % NonlinearityClass/effect, NonlinearityClass/update.        
            obj.A1=10^(val/20);%writing the value to A1 property 
            obj=update(obj);%update Aisat and Aosat properties
        end
        %% set.A3@NonlinearityClass
        %
        %  OBJ=set.A1(OBJECT,VALUE)
        %
        % Method invited when <NonlinearityClass.html#6 A3> is accessed for
        % writing. The member invites <NonlinearityClass.html#15 update> to compute
        % the values of <NonlinearityClass.html# Aisat> and <NonlinearityClass.html#
        % Aosat>. |VALUE| is considered to be in the linear scale.
        function obj=set.A3(obj,val)
        % SET.A3 - Method invited when NonlinearityClass/A3 property is acessed for
        % writing 
        %
        %   OBJ=set.A1(OBJECT,VALUE) -  Method invited when
        %   NonlinearityClass.html/A3 is accessed for writing. The member
        %   writes VALUE into the A3 filed of OBJECT, then 
        %   invites NonlinearityClass/update to compute the values of 
        %   NonlinearityClass/Aisat and NonlinearityClass/Aosat. VALUE is considered
        %   to be in the linear scale.
        %
        % See also: NonlinearityClass/NonlinearityClass, NonlinearityClass/set.A1,
        % NonlinearityClass/effect, NonlinearityClass/update.
        %
            obj.A3=val;%writing the value to A1 property 
            obj=update(obj);%update Aisat and Aosat properties
        end
        %% effect@NonlinearityClass
        % Gain and non-linearity is a common attribute of RF/analog blocks.
        % The effect is computed with the next formula:
        %
        % $$ y(k) =  \sum\limits_{n}{a_{n} \cdot x^{n}(k)} $$
        %
        % <html>
        % where <i>a<sub>1</sub></i> is the voltage gain and
        % <i>a<sub>3</sub></i> is the gain of the third order component.
        % </html>
        %
        %  OUTP=effect(OBJECT, INP)
        %
        % The method implements gain and nonlinearity attribiute of an
        % RF/analog block. The signal |INP| is recommended to be an object
        % of <SignalClass.html SignalClass>. The return |OUTP| is amplified 
        % and effected by non-linearity.
        %  
        function outp=effect(obj, vin)
        % PROCESS - Implements gain and non-linearity attribute RF/analog block. 
        %
        %	OUTP=effect(OBJECT, INP) - The method implements gain and
        %	nonlinearity attribiute of an RF/analog block. The signal INP
        %	is recommended to be an object of SignalClass. The return OUTP 
        %	is amplified and effected by non-linearity. 
        %
        % See also: NonlinearityClass/NonlinearityClass, NonlinearityClass/set.A1,
        % NonlinearityClass/set.A3, NonlinearityClass/update.
        %
            signal = vin.getSignal();
            mask1 = abs(vin) < obj.Aisat;
            rhoout = ((obj.A1 - obj.A3.*vin.*vin).*vin).*mask1;
            mask2 = (abs(vin) >= obj.Aisat) & (vin > 0);
            mask2 = mask2.*obj.Aisat;
            rhoout = rhoout + mask2;
            mask3 = (abs(vin) >= obj.Aisat) & (vin < 0);
            mask3 = -mask3.*obj.Aosat;
            outp = rhoout + mask3;
        end
    end
    methods (Access=private)
        %% update@NonlinearityClass
        %
        %  update(OBJECT);
        %
        % The method is executed when the object is constructed,
        % <NonlinearityClass.html#5 A1> or <NonlinearityClass.html#6 A3> are accessed. It
        % computes the input and output saturation voltages:
        %
        % $$ AI_{sat}=\frac{2}{3} \cdot \sqrt{\frac{a_{1}}{3\cdot a_{3}}},
        % AO_{sat}=\frac{2}{3} \cdot a_{1} \cdot AI_{sat} $$
        %
        function obj=update(obj)
            % UPDATE - Update input and output referred saturation voltages
            % and the 1dB compression point
            %
            %   update(OBJECT) - The method is executed when the object is constructed,
            %   NonlinearityClass.html/A1 or NonlinearityClass/A3 are accessed. It
            %   computes the input and output saturation voltages and the 1dB compression point:
            %
            %   Aisat=2/3*sqrt(A1/3/A3)
            %
            %   Aosat=2*A1*Aisat/3;
            %
            %   CP1=1000/2*0.1087^2*((A1/A3)^2)
            %
            % See also: NonlinearityClass/NonlinearityClass, NonlinearityClass/set.A1,
            % NonlinearityClass/set.A3, NonlinearityClass/effect.
            %            
            obj.Aisat=2/3*sqrt(obj.A1/3/obj.A3);
            obj.Aosat=2*obj.A1/3*obj.Aisat;
            obj.CP1=500*0.1087*0.1087*((obj.A1/obj.A3)^2); %in volts, not dB
        end
    end
end
