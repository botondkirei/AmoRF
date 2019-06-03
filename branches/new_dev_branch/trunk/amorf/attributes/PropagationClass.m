classdef PropagationClass < BaseClass
    properties
        %propagarea se intampla pe o linie de transmisie caracterizata de
        %timpul de propagare tau si impedanta liniei de transmisi Z
        tau
        Z
    end
    methods
        function output=effect(obj,inp)
        % semnalul rezultate se poate calcula cu urmatorul algoritm
        % recurziv:
        %% 1. conditii initiale: 1.1. valoarea tensiunii la terminalul
        % indepartat in intervalul -tau..tau; pentru incepat sa consideram 0
        % constant XFarEnd(-tau..tau)=0;
        %                       2.1. valoarea tensiunii la terminalul
        %apropiat in intervalul 0..2*tau cu urmatoarea formula: 
        %     XNearEnd(0..2*tau)=x(0..2*tau) + c1*XFarEnd(-tau..tau)
        %unde c1 este coeficientul de reflexie la terminalul indepartat
        %% 2. Calculul tensiunii la terminalul indepartat pentru intervalul
        % tau..3*tau: 
        %    XFarEnd(tau..3*tau)= c2 * XNearEnd(0..2*tau)
        %unde c2 este coeficientul de reflexie la terminalul apropiat
        %% 3. Calculul tensiunii la terminalul apropiat:
        %    XNearEnd(2*tau..4*tau)=x(2*tau..4*tau) + c1*XFarEnd(tau..3*tau)
        %% 4. Se poate observa un proces recurziv:
        %    XNearEnd(k*tau..(k+2)*tau)=x(k*tau..(k+2)*tau) + c1*XFarEnd((k-1)*tau..(k+1)*tau)
        %    XFarEnd((k+1)*tau..(k+3)*tau)= c2 * XNearEnd(k*tau..(k+2)*tau)
        %% 5. Se repata punctul 4. Pana cand (k+2)*tau < timpul simulat
        end
        
    end
end
