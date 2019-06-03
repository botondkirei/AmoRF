% IQImbalClass  - I/Q imbalance (or mismatch) in RF/analog blocks.
%
% IQImbalClass Properties:
%   g - amplitude error (an absolute value); the value of g can be
%       either a scalar or a vector matrix; frequency independent amplitude 
%       error is considered if the value of g is scalar 
%   phi - phase error (degrees); the value of phi can be either
%       a scalar or a vector matrix; frequency independent phase error
%       is considered if the value of phi is scalar
%   k1, k2 - imbalance parameters are automatically computed whenever
%       the amplitude of phase error is modified
%   IRR - image rejection ratio, automatically updated whenever the
%       amplitude or phase error is modified
%   IMG - image supression, the inverse of IRR, automatically updated whenever the
%       amplitude or phase error is modified
%
% IQImbalClass Methods:
%   set.g - Invited method when property G is accessed for writing.
%   set.phi - Invited method when property PHI is accessed for writing.
%   update - Method the update k1 and k2 properties and IRR and IMG.
%   effect - apply the I/Q imbalance to a signal.
%
% IQImbalClass Parent:
%   AttributeClass - functionalities and non-idealities
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, TunerClass, 
% GainClass, FreqSelClass, FreqConvClass, PhaseNoiseClass, NoiseClass.
classdef IQImbalClass < AttributeClass
%% IQImbalClass
% Parent class: <AttributeClass.html AttributeClass>.
% I/Q imbalance in RF/analog blocks.
%% Properties
% * <IQImbalClass.html#6 g>
% * <IQImbalClass.html#7 phi>
% * <IQImbalClass.html#8 k1>
% * <IQImbalClass.html#9 k2>
% * <IQImbalClass.html#10 IRR>
%% Inherited Properties
% <AttributeClass.html AttributeClass>
% * *Name* - Object name
%% Methods
% * <IQImbalClass.html#12 IQImbalClass>
% * <IQImbalClass.html#13 set.g>
% * <IQImbalClass.html#14 set.phi>
% * <IQImbalClass.html#15 effect>
% * <IQImbalClass.html#16 update>
properties
        % Amplitude error
        g 
        %% g
        % Amplitude error
        
        % Phase error
        phi
        %% phi 
        % Phase error
        
        % Imbalance parameter
        k1 
        %% k1
        % Imbalance parameter
             
        % Imbalance parameter
        k2 
        %% k2
        % Imbalance parameter
        
        % Image Rejection Rate
        IRR 
        %% IRR
        % Image Rejection Rate
        
        % Image Supression
        IMG 
        %% IMG
        % Image Suppression
    end
    methods
        %% IQImbalClass@IQImbalClass
        %
        %  OBJ=IQImbalClass(NAME)
        %
        % IQImbalClass object contructor. The IQImbalClass/Name property
        % is set to |NAME|.
        function obj=IQImbalClass(name)
        % IQImbalClass object constructor.
        %
        %   OBJ=IQImbalClass(NAME) - The IQImbalClass/Name property
        %   is set to NAME.
        %
        % See also: IQImbalClass/set.phi, IQImbalClass/effect,
        % IQImbalClass/update.
            obj.Name=name;
        end
        %% set.g@IQImbalClass
        %
        %   OBJ=set.g(OBJECT,VALUE)
        %
        % Method invited on the write acces of property
        % <IQImbalClass.html#6 g>. First the value is written to the
        % property, then <IQImbalClass.html#15 update> is executed. The
        % return OBJ is the updated copy of the object.
        %   
        function obj=set.g(obj,value)
        % SET.G - Method executed on write access of property
        % IQImbalClass/g.
        %
        %   OBJ=set.g(OBJECT,VALUE) - Writes VALUE to property
        %   IQImbalClass/g and invites IQImbalClass/update. The return OBJ
        %   is the updated copy of the object.
        %
        % See also: IQImbalClass/set.phi, IQImbalClass/effect,
        % IQImbalClass/update.
        
            obj.g=value;%writing the value of amplitude error
            obj=update(obj);%update imbalance parameters and IRR and IMG
        end

        %% set.phi@IQImbalClass
        %
        %   OBJ=set.phi(OBJECT,VALUE)
        %
        % Method invited on the write acces of property
        % <IQImbalClass.html#7 phi>. First the value is written to the
        % property, then <IQImbalClass.html#15 update> is executed. The
        % return |OBJ| is the updated copy of the object.
        function obj=set.phi(obj,value)
        % SET.PHI - Method executed on write access of property
        % IQImbalClass/phi.
        %
        %   OBJ=set.phi(OBJECT,VALUE) - Writes VALUE to property
        %   IQImbalClass/phi and invites IQImbalClass/update. The return OBJ
        %   is the updated copy of the object.
        %
        % See also: IQImbalClass/set.g, IQImbalClass/effect,
        % IQImbalClass/update.            
            obj.phi=value*pi/180;%converting and writing the value of phase error
            obj=update(obj);%update imbalance parameters and IRR and IMG
        end
        %% effect@IQImbalClass
        %
        % I/Q imbalance is a specific non-ideality of quadrature RF tuners.
        % It is mainly caused by amplitude and phase errors in the local
        % oscillation. If _g_ is the amplitude and _phi_ is the phase
        % error, then the imbalance parameters are defined as:
        %
        % $$ k_1=\frac{1+g \cdot e^{-j\phi}}{2}, k_2=\frac{1-g \cdot e^{j\phi}}{2}$$
        %
        % With the imbalance parameters the effect of I/Q mismatch is:
        %
        % $$ y(k)=k_1 \cdot x(k) + k_2 \cdot x^*(k)$$
        %
        % where _x_ and _y_ are complex valued signals.
        %
        %  OUTP=effect(OBJECT, INP)
        %
        % Apply the I/Q imbalance in the signal |INP| and the result is
        % returned |OUTP|. Signals |INP| and |OUTP| are recommened to
        % be an object derived from <SignalClass.html SignalClass>.
        function outp=effect(varargin)
            % PROCESS - Apply I/Q imbalance on signal.
            %
            %   OUTPUT = effect(OBJECT, INPUT) - Apply the I/Q imbalance
            %   in the signal INP and the result is	returned OUTP. Signals
            %   |INP| and |OUTP| are recommened to be an object derived from
            %	SignalClass.
            %
            % See also: IQImbalClass/set.g, IQImbalClass/set.phi,
            % IQImbalClass/update.
            obj=varargin{1};
            inp=varargin{2};
            outp=SignalClass(inp);
            switch length(obj.k1)
                case 1
                    v=obj.k1*inp.Samples  + obj.k2*conj(inp.Samples);
                    outp.Samples=v;
                otherwise
                    v= filter(obj.k1,inp.Samples)  + ...
                        filter(obj.k2,conj(inp.Samples));
                    outp.Samples=v;
            end     
        end
    end
    methods (Access=private)
        %% update@IQImbalClass
        % 
        %  update(OBJECT)
        %
        % Updates <IQImbalClass.html#8 k1>, <IQImbalClass.html#9 k2>,
        % <IQImbalClass.html#10 IRR> and <IQImbalClass.html#10 IMG> properties.
        function obj=update(obj)
            % UPDATE - Upadtes the imbalance parameters and IRR
            %
            % 	update(OBJECT) Updates <IQImbalClass.html#8 k1>,
            %	<IQImbalClass.html#9 k2> and <IQImbalClass.html#10 IRR>
            %	properties. 
            %	
            % See also: IQImbalClass/set.g, IQImbalClass/set.phi,
            % IQImbalClass/effect.
            obj.k1=(1+obj.g*exp(-1i*obj.phi))/2;
            obj.k2=(1-obj.g*exp(1i*obj.phi))/2;
            obj.IRR=db(abs(obj.k1./obj.k2));
            obj.IMG=db(abs(obj.k2./obj.k1));  
        end
    end
end