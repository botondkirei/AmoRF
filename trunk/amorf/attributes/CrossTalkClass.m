%modelul diafoniei electromagnetice intre canalele I si Q
%
classdef CrossTalkClass < IQImbalanceClass
    %membru pentru executia diafoniei intre canalele I/Q
    %diafonia pare pe o linie de transmisie
    methods
        function output=effect(varargin)
            obj=varargin{1};
            signal=varargin{2};
            output=signal;
            %07.01.2011 - nu sunt sigur daca formula pentru 
            %output.Samples = filter(obj.k1,signal.Samples)  + filter(obj.k2,conj(signal.Samples ));
        
        end
    end
end