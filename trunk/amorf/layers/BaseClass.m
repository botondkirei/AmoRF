% BaseClass Superclass of all the classes in amoRF toolbox.
%
%    Encapsulates the common methods of the amoRF toobox. The
%    methods are reserved for later use by the graphical user interface.
% 
% BaseClass properties:
%   Name - Object name
%
% BaseClass methods:
%   read - Read object properties
%   write - Write object properties
%   getstructure - get object property field structure
%
% See also: SignalClass, AttributeClass, BlockClass, TunerClass.
classdef BaseClass < handle
%% BaseClass
%
% Encapsulates the common methods of
% the amoRF toolbox. The methods are reserved for later use by the
% graphical user interface. 
%
%% Properties
%
% * <BaseClass.html#4 Name> - public
%
%% Methods
%
% * <BaseClass.html#5 write>
% * <BaseClass.html#6 read>
% * <BaseClass.html#7 getstructure>
%
% See also: <SignalClass.html SignalClass>, <AttributeClass.html
% AttributeClass>, <BlockClass.html BlockClass>, <TunerClass.html TunerClass>.
    properties 
        %Name of the the object. Default values is empty string.
        Name=''
        %% Name
        %
        % Name of the the object. Default values is empty string.
        
        % Structure to store the attributes of the RF/analog block or 
        % components for a Tuner   
        Architecture = {}
        %% Architecture
        % Structure to store the attributes of the RF/analog block. To add an 
        % attribute to a RF/analog block use <<BlockClass.html#11 add> method.
        
        % Output signal of RF/analog block. 
        Signal
        %% Signal
        % Output signal of RF/analog block. 
    end
    methods
        %% write@BaseClass
        %
        %  [OBJECT] = write(OBJECT,'PROPERTY',VALUE)
        %
        % The method saves |VALUE| (numeric) to |PROPERTY| (string) field of the OBJECT. 
        % The updated object is returned in OBJ.
        function write(obj,property,value)
        % Write values to the object's properties.
        %
        %   [OBJ] = write(OBJECT,'PROPERTY',VALUE) The 'PROPERTY' field of 
        %   the OBJECT will be updated with VALUE, and the updated object is returned in OBJ.
        % 
        % See also: BaseClass/read, BaseClass/getstructure.
                obj.(property)=value;
        end
        %% read@BaseClass
        %
        %  [VALUE] = write(OBJECT,'PROPERTY')
        %
        % The method returns the |VALUE| of OBJECTS's |PROPERTY|.
        function value=read(obj,property)
            % Read the value of the object properties. 
            %
            %    VALUE=read(OBJECT,'PROPERTY') The BaseClass/read member
            %    returns into the value of the OBJECT's 'PROPERTY' field.
            %
            % See also: BaseClass/write, BaseClass/getstructure.
            value=obj.(property);
        end
        %% add@BaseClass
        %
        %  add(OBJECT,ATTRIBUTE);
        %
        % The Method is used to add attributes to RF/analog block. An
        % RF/analog block consists of several nonidealities. |ATTRIBUTE| can be
        % either an instance of a AttributeClass or it's derived classes
        % that complies with <BlockClass.html#9 run> member. 
        function obj=add(obj,attribute)
        % Add an attribute to the RF/analog block.
        %
        %  add(OBJECT,ATTRIBUTE);
        %
        % The Method is used to add attributes to RF/analog block. An
        % RF/analog block consists of several nonidealities. ATTRIBUTE can be
        % either an instance of a AttributeClass or it's derived classes
        % that complies with BlockClass/run member.
            obj.Architecture={obj.Architecture{:}, attribute};
        end
                 %% run@BaseClass
         % 
         %  OBJ=run(OBJECT,INP)
         %
         % Computes the output of the RF tuner/analog block and saves it to
         % signal |INP|. The funtion returns an object of BaseClass.
         %
         %  [OBJ,OUTP]=run(OBJECT,INP)
         %
         % Computes the output of the RF tuner/analog block and saves it to
         % signal |INP|. The funtion returns an object of BaseClass.
         % 
         function outp=run(obj,inp)
         %PROCESS Computes the response of the RF tuner/block to a signal
         %
         %   OBJ=run(OBJECT,INP) Computes the output of an RF tuner/block 
         %   to signal |INP|. The funtion returns an object of BaseClass. 
         %
         % See also: TunerClass/TunerClass, BlockClass/BlockClass
         %
            outp = inp; 
            for i=1: size(obj.Architecture,2)
                component=obj.Architecture{i};
                outp=component.run(outp);
            end
            obj.Signal = outp;
         end
        %% getstructure@BaseClass
        %
        %  ROOT = getstructure(OBJECT)
        %
        % The method returns the object properties in a
        % <matlab:doc('uitree') uitree> structure.
        function root=getstructure(obj)
            % Return the property names in a tree view structure
            %
            %    ROOT = getstructure(OBJECT) The method returns the
            %    OBJECT's properties in a uitree structure
            %
            % See also: BaseClass/write, BaseClass/read.
            root=uitreenode('v0','root',obj.Name,[],false);
            branches = fieldnames(obj);
            [a,b] = size(branches);
            for i=1:a
                branchname=char(branches(i));
                s.name=[branchname, '10'];
                s.val=10;
                branch=uitreenode('v0','branch',s,[],true);
                root.add(branch);
            end
        end
        
    end
end