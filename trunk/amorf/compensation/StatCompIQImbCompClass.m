classdef StatCompIQImbCompClass < IQImbalCompClass
    methods
        function obj=StatCompIQImbCompClass(name)
            obj=obj@IQImbalCompClass(name);
        end
        function estimate(obj,d,v)
            %prod=mean(d.*v)/mean(abs(d+conj(v)).^2);
            prod=obj.cov(d,v)/var(d+conj(v));
            gain=sqrt(1-4*real(prod));
            phase=asin(-2/gain*imag(prod));

            obj.k1=(1+gain*exp(-sqrt(-1)*phase))/2; %imbalance parameters
            obj.k2=(1-gain*exp(sqrt(-1)*phase))/2; %imbalance parameters
        end
        function value=IRR(obj)
            value=db(abs(obj.k2./obj.k1));
        end
        function value=IRRcomp(obj,k1,k2)
            k1e=obj.k1;
            k2e=obj.k2;
            value = db(abs((k2*conj(k1e)-k1*conj(k2e))/(k1*conj(k1e)-conj(k2)*k2e)));
        end
        function value = cov(obj,signal1,signal2)
            value = mean((signal1-mean(signal2)).*(signal2-mean(signal2)));
        end
        function test4(obj)
            N=10000;
            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            signal=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);
            image=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);   
            mean(signal)
            mean(image)
            mix1=fft(k1*signal+k2*conj(image));
            mix2=fft(k1*image+k2*conj(signal));
            mean(mix1)
            mean(mix2)
            obj.process([mix1(2:end) mix2(end:-1:2)]);
            k1e=obj.k1;
            k2e=obj.k2;
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(k1e)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(k2e)]);
            disp(num2str(db(abs(k2./k1))));
            disp (['IRR after compensation = ',num2str(obj.IRRcomp(k1,k2))]);
        end
        function test3(obj)
            N=10000;
            M=16;
            hm = modem.qammod(M);
            
            data=randi(M,N,1)-1;
            signal = modulate(hm,data);

            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            r=k1*signal+k2*conj(signal);
            obj.process(r);
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(obj.k1)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(obj.k2)]);
            disp (['IRR after compensation = ',num2str(obj.IRRcomp(k1,k2))]);
        end    
        function test2(obj)
            N=10000;
            M=16;
            hm = modem.qammod(M);
            
            data=randi(M,N,1)-1;
            signal = modulate(hm,data);
            data=randi(M,N,1)-1;
            image = modulate(hm,data);
            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            mix1=k1*signal+k2*conj(image);
            mix2=k1*image+k2*conj(signal);
            comp = obj.process([mix1 mix2]);
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(obj.k1)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(obj.k2)]);
            %disp (['IRR after compensation = ',num2str(obj.IRRcomp(k1,k2))]);
        end
        function test0(obj,N)
            disp('StatCompIQImbCompClass selftest');
            disp('amplitude error g = 1.1; phase error phi = 3 degrees');
            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            signal=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);
            image=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);   
            mix1=k1*signal+k2*conj(image);
            mix2=k1*image+k2*conj(signal);
            comp = obj.process([mix1 mix2]);
            k1e=obj.k1;
            k2e=obj.k2;
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(k1e)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(k2e)]);
%             se=comp(:,1);
%             ve=comp(:,2);
%             plot(abs(fft(signal-se)));
            
        end
        function test1(obj,N)
            disp('StatCompIQImbCompClass selftest');
            disp('Test if the algorithm works if a phase mismatch is introduced');
            disp('amplitude error g = 1.1; phase error phi = 3 degrees');
            N=10000;
            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            signal=randn(N,1)+1i*randn(N,1);
            mix1=k1*signal+k2*conj(signal);
            mix2=(k1*signal+k2*conj(signal));%*exp(1i*pi/8);
            mix2=[mix2(10:end);mix2(1:9)];
            comp = obj.process([mix1 mix2]);
            k1e=obj.k1;
            k2e=obj.k2;
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(k1e)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(k2e)]);
%             se=comp(:,1);
%             ve=comp(:,2);
%             plot(abs(fft(signal-se)));
            
        end
    end
end