classdef SubbandIQImbalCompClass < BaseClass
%SubBandIQMismCompClass - I/Q mismatch compensation class for frequency
%selective I/Q mismatch
%
%   comp = SubBandIQMismCompClass(); %instantiation of the class
%
%   [xe,ye]=comp.process(x,y,power); % processing two subband signals
%
%   x and y are complex valued signals form two subbands, for correct 
%   operation it is supposed that the powers in the two subbands are equal 
%   it is desired for x and y to be instances of SignalClass;
%
%   The input signals x and y are supposed to be mixtures of the next form:
%           x=k1  * s       + k2  * conj(i)
%           y=k2p * conj(s) + k1p * i
%   where s is the desired signal, i is the interferer signal, k1, k2 are
%   the imbalance parameters in one subband and k1p and k2p are from the
%   second subband;     properties
    properties
        k1
        k2
        k1p
        k2p
    end
    methods
        function output=process(obj,input,power,fourth)
            [a,b] = size(input);
            if b==1
                obj.estimate(input, input, power,fourth);
                output=(conj(obj.k1p).*input-obj.k2.*conj(input))/(obj.k1*conj(obj.k1p)-obj.k2*conj(obj.k2p));
            else
                signal = input(:,1);
                image = input(:,2);
                obj.estimate(signal,image, power,fourth);
                signal=(conj(obj.k1p)*signal-obj.k2*conj(image))/(obj.k1*conj(obj.k1p)-obj.k2*conj(obj.k2p));
                image=(conj(obj.k1)*image-obj.k2p*conj(signal))/(obj.k1p*conj(obj.k1)-conj(obj.k2)*obj.k2p);
                output = [signal image];
            end
        end
        function value = cov(obj,signal1,signal2)
            value = mean((signal1-mean(signal2)).*(signal2-mean(signal2)));
        end
        function estimate(obj,signal, image, power,fourth)
            
            g=sqrt(var(signal)/power - 1);
            gp=sqrt(var(image)/power - 1);
            
            Est4th = imag(mean(signal.^4));
            
            syms x;
            s=eval(solve((g/2*sin(x)+g^3/2*sin(3*x))*real(fourth)+Est4th));
            
            for i=1:6
                value = s(i);
                if abs(value)<1
                    phi=real(value);
                    break;
                end
            end
            
            covariance=obj.cov(signal,image);
            value=eval(solve( (gp*sin(x)+g*sin(phi))*power + imag(covariance) ));
            
            for i=1:length(value)
                if value(i)<1
                    phip=value(i);
                    break;
                end
            end            
            
            obj.k1=(1+g*exp(-phi*1i))/2;
            obj.k2=(1-g*exp(phi*1i))/2;
            obj.k1p=(1+gp*exp(-phip*1i))/2;
            obj.k2p=(1-gp*exp(phip*1i))/2;
        end
        function test1(obj)
            disp('This test case generates a mixture that is prodused in');
            disp('the presence of frequency selective I/Q mismatch');
            disp('g=1.2 phi=4 degrees');
            disp('g=1.1 phi=3 degrees');
            disp('the power of the mixed signals are equal and considered to be known.')
            disp('the difference between the original and the recovered signal is plotted')
            disp('if the difference is under -50dB than its working')
            N=30000;
            g=1.2; phi=4*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            gp=1.1; phip=3*pi/180;
            k1p=(1+gp*exp(-1i*phip))/2; k2p = (1-gp*exp(1i*phip))/2;
            signal=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);
            image=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5); 
            mix1=k1*signal+k2*conj(image);
            mix2=k1p*image+k2p*conj(signal);
            
            power=mean(real(signal).^2);
            fourth=mean(signal.^4);
            
            output=obj.process([mix1 mix2],power,fourth);
            rs=output(:,1);
            ri=output(:,2);
            
            subplot(2,1,1);plot(db(abs(signal-rs)));
            subplot(2,1,2);plot(db(abs(image-ri)));
        end
        function test2(obj)
            disp('This test case generates a mixture that is prodused in');
            disp('the presence of frequency selective I/Q mismatch');
            disp('g=1.2 phi=4 degrees');
            disp('g=1.1 phi=3 degrees');
            disp('the power of the mixed signals are equal and considered to be known.')
            N=30000;
            g=1.2; phi=4*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            gp=1.1; phip=3*pi/180;
            k1p=(1+gp*exp(-1i*phip))/2; k2p = (1-gp*exp(1i*phip))/2;
            signal=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);
            image=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5); 
            mix1=k1*signal+k2*conj(image);
            mix2=k1p*image+k2p*conj(signal);
            
            power=mean(real(signal).^2);
            fourth=mean(signal.^4);
            
            obj.estimate(mix1,mix2,power,fourth);
            
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(obj.k1)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(obj.k2)]);
            disp (['k1p = ', num2str(k1p), ', k1p estimate = ', num2str(obj.k1p)]);
            disp (['k2p = ', num2str(k2p), ', k2p estimate = ', num2str(obj.k2p)]);
            
        end
    end
end