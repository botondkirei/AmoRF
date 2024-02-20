% BlockClass - Aggregate class of attributes to create behavioral RF/analog
% block models.
%
% BlockClass properties:
%   Architecture - structure of RF/analog block
%   Signal - output signal of RF/analog block
%   Zin - input impedance
%   Zout - output impdance
%
% BlockClass methods:
%   BlockClass - object constructor
%   add - add attributes to RF/analog block
%   run - compute the response to the input signal
%   nf - get noise figure of RF/analog block
%   gain - get voltage gain (without load) of RF/analog block
%   temp  - get equvalent temperature of RF/analog block
%   compoint - get the 1dB compression point of RF/analog block
%   imgs - get the image suppression of the mixer block
%   getstructure - return an uitree structure of BlockClass/Architecture property
%
% BlockClass parents:
%   AttributeClass - functionalities and non-idealities of an RF/analog block.
%
% See also: BaseClass, SignalClass, AttributeClass, TunerClass, GainClass,
% NoiseClass, FreqSelClass, FreqConvClass, PhaseNoiseClass, IQImbalClass.
% 
% classdef BlockClass < AttributeClass
classdef BlockClass < BaseClass
%% BlockClass
% Parent Class: <AttributeClass.html AttributeClass> and
% <matlab:doc('handle') handle>. 
%
% Aggregate class of attributes to create behavioral RF/analog block
% models. It is derived form <BaseClass.html BaseClass> and inherits all
% common methods from it.

%% Properties
% * <BlockClass.html#6 Architecture>
% * <BlockClass.html#7 Signal>
% * <BlockClass.html#8 Zin>
% * <BlockClass.html#9 Zout>
%% Inherited Properties 
% <AttributeClass.html AttributeClass>
%
% * <AttributeClass.html#9 AggObj> - Handle to the RF receiver object.
% 
% <BaseClass.html BaseClass>
%
% * <BaseClass.html#3 Name> - Name of the object.
% 
%
%% Methods
% * <BlockClass.html#11 constructor>
% * <BlockClass.html#12 add>
% * <BlockClass.html#13 run>
% * <BlockClass.html#14 gain>
% * <BlockClass.html#15 nf>
% * <BlockClass.html#16 compoint>
% * <BlockClass.html#17 temp>
% * <BlockClass.html#18 getstructure>
    properties
        % Input impedance of the next analog/RF block. Default value 50 Ohm.
        Znext=50
        %% Znext
        % Input impedance of the next analog/RF block. Default value 50 Ohm.
        
        % Output impedance of the RF component. Default value 50 Ohm.
        Zout=50
        %% Zout
        % Output impedance of the RF component. Default value 50 Ohm.
    end
    methods
        %% BlockClass@BlockClass
        %
        %  OBJ=BlockClass(NAME);
        %
        % Constructor methods of BlockClass. The method initialize the
        % <BlockClass.html# Signal> property to |SignalClass(0,0)| and
        % <BlockClass.html# Name> to |NAME|. The return value |OBJ| is the 
        % instantiation of BlockClass.
        function obj=BlockClass(name)
        % Constructor method
        %
        %	OBJ=BlockClass(NAME) - Constructor method of BlockClass. The
        %	method initialize the BlockClass/Signal property to
        %	SignalClass(0,0) and BlockClass/Name to NAME. The return value
        %	OBJ is the instantiation of BlockClass.
            obj.Name=name;
            obj.Signal=SignalClass(0,0);
            obj.Signal.Name = [name 'output signal'];
        end

        %% run@BlockClass
        %
        %  OBJ=run(OBJECT,INP)
        %
        % The method computes the response of the RF/analog block of the
        % input signal |INP| (instance of <SignalClass.html SignalClass>). It 
        % evaluates the attributes included in |OBJECT.Architecture|
        % property in the order they were added to |OBJECT|. |OUTP| is
        % obtained by passing |INP| to the |run| methods of the   
        % attributes.
        function    outp=run(obj,inp)
        % Compute the response of the RF/analog block
        %
        %   OBJ=run(OBJECT,INP) The method computes the response of the
        %   RF/analog block of the input signal INP (instance of SignalClass).
        %   It evaluates the attributes included in OBJECT.Architecture
        %   property in the order they were added to OBJECT. OUTP is
        %   obtained by passing INP to the RUN methods of the
        %   attributes.
        % 
        % See also: BlockClass/getstructure, BlockClass/gain, BlockClass/nf,
        % BlockClass/add, BlockClass/temp , BlockClass/compoint, BlockClass/imgs       
            outp = inp;
            for i=1: size(obj.Architecture,2)
                component=obj.Architecture{i};
                outp=component.run(outp);
            end
            thermalnoise = NoiseClass('Noise');
            thermalnoise.R=obj.Zout+obj.Znext;
            thermalnoise.B=outp.Fs;
            noise = thermalnoise.getNoise(outp.length);
            outp = outp.addNoise(noise);
            outp = outp.*(obj.Znext/(obj.Zout+obj.Znext));
            obj.Signal = outp;
            obj.Signal.Name=obj.Name;
        end
        %% nf@BlockClass
        %
        %  VALUE=nf(OBJECT)
        %
        % Returns the noise figure of the RF/analog block |OBJECT|. |NF| is
        % stored in the <NoiseClass.html NoiseClass> attribute. This method
        % interrogates all the included attributes for the noise figure
        % <NoiseClass.html# NoiseClass/NF> and returns to |VALUE|. Good
        % practice is to include NoiseClass attribute to every RF/analog
        % block.
        function value=nf(obj)
        % Returns the Noise Figure of the RF.
        %
        %	VALUE=nf(OBJECT) Returns the noise figure of the RF/analog
        %	block OBJECT. NF is stored in the NoiseClass/NF attribute.
        %   This method interrogates all the included attributes for
        %   the noise figure NoiseClass/NF and returns to VALUE.
        %   Good practice is to include NoiseClass attribute to every
        %   RF/analog block. 
        %
        % See also: BlockClass/run, BlockClass/gain, BlockClass/getstructure,
        % BlockClass/add, BlockClass/temp,
        % BlockClass/compoint, BlockClass/imgs
        %
            components = fieldnames(obj.Architecture);
            [a,b] = size(components);
            arch=obj.Architecture;
            for i=1:a
                b=getfield(arch,char(components(i)));
                try
                    value=b.nf;
                catch 
                end
            end
        end
        %% compoint@BlockClass
        %
        %  VALUE=compoint(OBJECT)
        %
        % Returns the 1dB compression point of the RF/analog block |OBJECT|. The
        % compression point is stored in the <GainClass.html GainClass>
        % attribute. This method interrogates all the included attributes
        % for the compression point <GainClass.html GainClass/A1) and returns to |VALUE|. Good
        % practice is to include GainClass attribute to every RF/analog 
        % block.
        function value=compoint(obj)
        % COMPOINT returns the 1dB compression point.
        %
        %   VALUE=compoint(OBJECT) Returns the 1dB compression point of the RF/analog
        %   block OBJECT. The 1dB compression point is stored in the GainClass
        %   attribute. This method interrogates all the included attributes
        %   for the 1dB compression point GainClass/CP1 and returns to VALUE.
        %   Good practice is to include GainClass attribute to every
        %   RF/analog block. 
        % 
        % See also: BlockClass/run, BlockClass/getstructure, BlockClass/nf,
        % BlockClass/add, BlockClass/temp, BlockClass/imgs
            components = fieldnames(obj.Architecture);
            [a,b] = size(components);
            arch=obj.Architecture;
            for i=1:a
                b=getfield(arch,char(components(i)));
                try
                    value=b.CP1;
                catch me
                end
            end
        end
        %% gain@BlockClass
        %
        %  VALUE=gain(OBJECT)
        %
        % Returns the volatge gain (without load) of the RF/analog block |OBJECT|. The
        % voltage gain is stored in the <GainClass.html GainClass>
        % attribute. This method interrogates all the included attributes
        % for the voltage gain <GainClass.html GainClass/A1) and returns to |VALUE|. Good
        % practice is to include GainClass attribute to every RF/analog 
        % block.
        function value=gain(obj)
        % GAIN returns the voltage gain (without load).
        %
        %   VALUE=gain(OBJECT) Returns the volatge gain of the RF/analog
        %   block OBJECT. The voltage gain is stored in the GainClass
        %   attribute. This method interrogates all the included attributes
        %   for the voltage gain GainClass/A1 and returns to VALUE.
        %   Good practice is to include GainClass attribute to every
        %   RF/analog block. 
        % 
        % See also: BlockClass/run, BlockClass/getstructure, BlockClass/nf,
        % BlockClass/add, BlockClass/temp, BlockClass/compoint,
        % BlockClass/imgs
        
            components = fieldnames(obj.Architecture);
            [a,b] = size(components);
            arch=obj.Architecture;
            for i=1:a
                b=getfield(arch,char(components(i)));
                try
                    value=b.A1;
                catch me
                end
            end
        end
        %% temp@BlockClass
        %
        %  VALUE=temp(OBJECT)
        %
        % Returns the voltage equivalent temperature of the RF/analog block |OBJECT|. The
        % equivalent temperature is stored in the <NoiseClass.html NoiseClass>
        % attribute. This method interrogates all the included attributes
        % for the equivalent temperature NoiseClass/Temp and returns to |VALUE|. Good
        % practice is to include NoiseClass attribute to every RF/analog 
        % block.
        function value=temp(obj)
        % Returns the volatge equivalent temperature of the RF/analog block
        %
        %	VALUE=temp(OBJECT) Returns the volatge equivalent temperature of
        %	the RF/analog block OBJECT. The equivalent temperature is
        %	stored in the NoiseClass> attribute. This method interrogates all
        %   the included attributes for the equivalent temperature
        %   NoiseClass/Temp and returns to VALUE. Good practice is to
        %   include NoiseClass attribute to every RF/analog block.
        %  
        % See also: BlockClass/run, BlockClass/gain, BlockClass/nf,
        % BlockClass/add, BlockClass/getstructure, BlockClass/compoint,
        % BlockClass/imgs
        % 
            components = fieldnames(obj.Architecture);
            [a,b] = size(components);
            arch=obj.Architecture;
            for i=1:a
                b=getfield(arch,char(components(i)));
                try
                    value=b.Te;
                catch me
                end
            end
        end
        %% imgs@BlockClass
        %
        %  VALUE=imgs(OBJECT)
        %
        % Returns the image suppression of the RF/analog block |OBJECT|. The
        % image supression is stored in the <IQImbalClass.html IQImbalClass>
        % attribute. This method interrogates all the included attributes
        % for the image supression <IQImbalClass.html IQImbalClass/IMG) and
        % returns to |VALUE|. 
        function value=imgs(obj)
        % IMGS returns the image supression.
        %
        %   VALUE=imgs(OBJECT) Returns the image suppression of the RF/analog block |OBJECT|. The
        % image supression is stored in the <IQImbalClass.html IQImbalClass>
        % attribute. This method interrogates all the included attributes
        % for the image supression <IQImbalClass.html IQImbalClass/IMG) and
        % returns to |VALUE|. 
        % 
        % See also: BlockClass/run, BlockClass/getstructure, BlockClass/nf,
        % BlockClass/add, BlockClass/temp, BlockClass/compoint,
        % BlockClass/gain
            components = fieldnames(obj.Architecture);
            [a,b] = size(components);
            arch=obj.Architecture;
            for i=1:a
                b=getfield(arch,char(components(i)));
                try
                    value=b.IMG;
                catch me
                end
            end
        end
        %% getstructure@BlockClass
        %
        %  ROOT=getstructure(OBJECT)
        %
        % The method returns the object properties in a
        % <matlab:doc('uitree') uitree> structure. 
        function root=getstructure(obj)
            % Return the property names in a tree view structure
            %
            %    ROOT = getstructure(OBJECT) The method returns the
            %    OBJECT's properties in a uitree structure.
            %
            % See also: BlockClass/run, BlockClass/gain, BlockClass/nf,
            % BlockClass/add, BlockClass/temp, BlockClass/compoint
            %
            root=uitreenode('v0','root','Architecture',[],false);
   
            for i=1:size(obj.Architecture,2)
                branchname=obj.Architecture{i}.Name;
                branch=uitreenode('v0','branch',branchname,[],false);
                component=obj.Architecture{i};
                for j=1:size(component,2)
                    try component.Architecture 
                         leaf=obj.Architecture{j}.getstructure;
                    catch 
                         leaf=uitreenode('v0','branch',[component.Name],[],true);
                    end    
                    branch.add(leaf);
                end
                root.add(branch);
            end
        end

    end
    methods (Static)
        %% selftest@BlockClass
        %
        %  selftest(OBJECT)
        %
        function selftest()

            gain=GainClass('gain'); % create a non-linearity object
            gain.A1=10; % set the component gain
            gain.A3=0.001;
            amplif = BlockClass('block'); % instatiate an object of BlockClass
            amplif.add(gain); % add the nonlinearity object
            a=amplif.run(SignalClass(sin(1:100),1));
            a.plot;
                       
       end
    end
end
% An RF component exhibits several non-idealities, but special attention
% should be accorded to the thermal noise and the nonlinearity. Using these
% two nonidealities the noise figure and the gain of the RF blocks are
% modelled. 
%
% The procedure of creating a RF component model comprises in a
% few steps. First the objects of nonidealities are instatiated, then an
% object of <../amorf/generic/html/CompomentClass.html BlockClass> is
% created. Next use the add member of the
% <../amorf/generic/html/CompomentClass.html BlockClass> object in
% order to include the non-ideality objects into the component
% model. The noise figure of the RF component is modelled using the thermal
% noise object, so the noise figure property of the later object should be
% written. The gain of the RF component is modeled by the nonlinearity
% object. The idea is to set the linearity as high as possible in order to
% not run the runed signal.

%gain=NonLinearityClass; % create a non-linearity object
%gain.a1=10; % set the component gain
%gain.a3=0.001; % set the third order gain near to 0
%amplif = BlockClass; % instatiate an object of BlockClass
%amplif.add('Thermal', thermal); % add the thermal noise object
%amplif.add('Gain',gain); % add the nonlinearity object
%signal=amplif.run(signal); % run a signal