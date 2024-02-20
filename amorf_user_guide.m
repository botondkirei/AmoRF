%% User Guide
%
%% Built-in and User Defined Attributes
%
% *AttributeClass.*
% <AttributeClass.html AttributeClass> provides a template for the 
% functionalities and non-idealities of the Rf/analog blocks going to be
% modeled with the toolbox. To find out more about the build-in 
% attrib utes inspect <classes.html#2 Attribute Classes>.
%
% *User Defined Attributes.*
% A user defined functionality or non-ideality class should be derived from
% <AttributeClass.html AttributeClass>. To keep the new class compatible
% with exiting functionalities, the header of <AttributeClass.html#4 effect>
% member should be the same (the input of the method is the
% signal that is going to be affected by the nonideality, the output is the
% affected signal). An example is provided in the documentation of
% <AttributeClass.html#5 AttributeClass>.

%% Modeling an RF/analog blocks
%
% <BlockClass.html BlockClass> in the toolbox is considered to be 
% aggregate class of attributes. The best practice is to instantialize 
% objects of attributes and include them to a RF/analog block model. An 
% example is provided in <BlockClass.html# BlockClass>.

%% Modeling an RF receiver
%
% <html>
% The amo<font style="color:990000">RF</font> toolbox provides
% functions for the user to "design" it's own receiver through cascading
% RF/analog blocks. See the modeling or a Direct Conversion Receiver (DCR) in 
% <a href="TunerClass.html">TunerClass</a>.
% </html>
%
% <TunerClass.html TunerClass> arrives with functions to compute the
% equivalent noise figure (or the receiver temperature) and the overall
% receiver nonlinearity.