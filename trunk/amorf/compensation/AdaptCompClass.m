classdef AdaptCompClass < IQImbalCompClass
    properties
        w1=0.5;
        w2=0.5;
        nu=0.0005
        debug = false
    end
    methods
        function obj=AdaptCompClass(name,debug,nu,w1i,w2i)
            obj=obj@IQImbalCompClass(name);
            switch nargin 
                case 2
                    obj.debug = debug;
                case 3
                    obj.debug = debug;
                    obj.nu=nu;
                case 4
                    obj.w1=w1i;
                    obj.w2=w2i;
                    obj.debug = debug;
            end
        end
        function obj=estimate(obj,signal,image)
            obj.adapt(signal,image);
            %when adaptation is done the weigth values are supposed to
            %adapt to w1=conj(k1)/k2 and w2=conj(w1); in addition we know
            %that k1+conj(k2)=conj(k1)+k2=1; if one divides both sides of
            %the latter ideintity then gets conj(k1)/k2+1=1/k2; from here
            %k2=1/(1+w1)
            obj.k1=1/(1+obj.w1);
            obj.k2=conj(obj.w1*obj.k1);
        end
    end
    
    methods
        function [output]=adapt(obj,signal,image)
            if nargout == 0
                if obj.debug 
                   W=[];
                end                
                for i=1:length(signal)
                    s = signal(i);
                    sc = conj(image(i));
                    e1=sc-obj.w1*s;
                    e2=s-obj.w2*sc;
                    obj.w1=obj.w1+2*obj.nu*e1*conj(e2);
                    obj.w2=obj.w2+2*obj.nu*e2*conj(e1);
                    if obj.debug 
                       W=[W;obj.w1 obj.w2];
                    end
                end
                if obj.debug 
                    subplot(2,2,1);plot(real(W(:,1)));
                    subplot(2,2,2);plot(imag(W(:,1)));
                    subplot(2,2,3);plot(real(W(:,2)));
                    subplot(2,2,4);plot(imag(W(:,2)));
                end
            else
                e1vector=[];e2vector=[];W=[];
                for i=1:length(signal)
                    s = signal(i);
                    sc = conj(image(i));
                    e1=sc-obj.w1*s;
                    e1vector=[e1;e1vector];
                    e2=s-obj.w2*sc;
                    e2vector=[e2;e2vector];
                    obj.w1=obj.w1+2*obj.nu*e1*conj(e2);
                    obj.w2=obj.w2+2*obj.nu*e2*conj(e1);
                    if obj.debug  
                        W=[W;obj.w1 obj.w2];
                    end
                end
                output=[e2vector e1vector];
                if obj.debug 
                    subplot(2,2,1);plot(real(W(:,1)));
                    subplot(2,2,2);plot(imag(W(:,1)));
                    subplot(2,2,3);plot(real(W(:,2)));
                    subplot(2,2,4);plot(imag(W(:,2)));
                end
            end
            obj.k1=1/(1+obj.w1);
            obj.k2=conj(obj.w1*obj.k1);
        end
        function test1(obj)
            N=30000;
            g=1.1; phi=2*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            k1p=k1'; k2p = k2';
            signal=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);
            image=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5); 
            mix1=k1*signal+k2*conj(image);
            mix2=k1p*image+k2p*conj(signal);
            rec=obj.adapt(mix1,mix2,true);
            %rec=obj.process([mix1,mix2]);
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(obj.k1)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(obj.k2)]);
            plot(db(abs(rec(:,1)/(1-obj.w1*obj.w2)-signal)));            
        end
        function test2(obj)
            N=30000;
            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            signal=(rand(N,1)-0.5)+1i*(rand(N,1)-0.5);
            mix=k1*signal+k2*conj(signal);
            obj.estimate(mix,mix);
            disp (['k1 = ', num2str(k1), ', k1 estimate = ', num2str(obj.k1)]);
            disp (['k2 = ', num2str(k2), ', k2 estimate = ', num2str(obj.k2)]);
            [rec]=obj.effect(mix);
            plot(db(abs(rec-signal)));
        end
    end
end