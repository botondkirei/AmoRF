classdef SignalContainerClass < SignalClass
    % This class contains samples of a OFDM signal generated with a
    % spetialized tool
    methods 
        function obj=SignalContainerClass;
            obj.Fs=9.1429e6;
            obj.Fc=15e6;
        end
    end  
end