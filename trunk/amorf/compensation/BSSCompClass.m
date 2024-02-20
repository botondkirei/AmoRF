classdef BSSCompClass < IQImbalCompClass
    properties
        learning_rate=0.00001
        alfa=0.2
        B
    end
    methods 
        function obj=BSSCompClass(name)
            obj=obj@IQImbalCompClass(name);
            obj.B = eye(2);
        end
        function output=H(obj,y)
            output = y*y' -eye(2)+obj.f1(y)*y'-y*(obj.f1(y))';
        end
        
        function output=f1(obj,y)
            output=y;
            for i=1:2
                if (y(i)^2 < obj.alfa) 
                    output(i)=-conj(y(i));
                else 
                    output(i)=0;
                end
            end
        end
        function output=f2(obj,y)
            output=sqrt(obj.alfa+real(y))+1i*sqrt(obj.alfa+imag(y));
        end
        function output=f3(obj,y)
            output=y.^2/2 ;
        end
        function output=f4(obj,y)
            output=y.*abs(y).^2/3;
        end
        function y=estimate(obj,signal,image)
            Ps=mean(abs(signal));
            signal=signal/Ps;
            Pi=mean(abs(image));
            image=image/Pi;
            I=eye(2);
            x=[signal conj(image)].';
            B = obj.B;
            y=zeros(size(x));
            TraceB=zeros(2,2*length(x));
            for i=1:length(x)
                y(:,i) =B*x(:,i);
                B=(I-obj.learning_rate*obj.H(y(:,i)).')*B;
                TraceB(:,i*2-1:i*2)=B;
                if (false)
%                     B(1,1)=(B(1,1) + B(2,2)')/2;
%                     B(2,2)=B(1,1)';
%                     B(2,1)=(-B(1,2)-B(2,1)')/2;
%                     B(1,2)=B(2,1)';
                    %B=inv(Bi);
                    B(1,1)=(B(1,1)+B(2,2))/2;
                    B(2,2)=B(1,1);
                    B(1,2)=-(B(2,1)-B(1,2))/2;
                    B(2,1)=B(1,2);
                end
            end
            obj.B=B;
            % itt azt feltetelezem, hogy a b inverze pont a K 
            Bi=inv(B);
            obj.k1=Bi(1,1);
            obj.k2=Bi(1,2);
            y(1,:)=y(1,:)*Ps;
            y(2,:)=y(2,:)*Pi;
            %adaptation can be constrained if 'false' is changed to 'true'

        end
        function test1(obj)
            disp('This test case generates a mixture that is prodused in');
            disp('the presence of frequency selective I/Q mismatch');
            disp('g=1.2 phi=4 degrees');
            disp('g=1.1 phi=3 degrees');
            disp('the power of the mixed signals are equal and considered to be known.')
            N=10000;

            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            gp=1.2; phip=4*pi/180;
            k1p=(1+gp*exp(-1i*phip))/2; k2p = (1-gp*exp(1i*phip))/2;
            signal=(rand(N,1)-.5)+1i*(rand(N,1)-.5);
            image=(rand(N,1)-.5)+1i*(rand(N,1)-.5); 
            mix1=k1*signal+k2*conj(image);
            mix2=k1p*image+k2p*conj(signal);
            m1=mean(mix1);
            m2=mean(mix2);
            mix1=mix1-m1;
            mix2=mix2-m2;
            p1=mean(abs(mix1));
            mix1=mix1/sqrt(p1);
            p2=mean(abs(mix1));
            mix2=mix2/sqrt(p2); 
%             mix1(1)=[];
%             mix2(1)=[];
            
            res=obj.effect([mix1 mix2]);
            
            %subplot(2,1,1); plot(db(abs(signal-p)))
            
            K=[[k1 k2];[k2p k1p]]
            Kp=[[obj.k1 obj.k2];[obj.k2p obj.k1p]]
            %%Kp./K
            


            
        end
        function test2(obj)
            disp('This test case generates a mixture that is prodused in');
            disp('the presence of frequency selective I/Q mismatch');
            disp('g=1.2 phi=4 degrees');
            disp('g=1.1 phi=3 degrees');
            disp('the power of the mixed signals are equal and considered to be known.')
            N=10000;
            M=16;
            hm = modem.qammod(M);
            
            data1=randi(M,N,1)-1;
            signal = modulate(hm,data1);
            data2=randi(M,N,1)-1;
            image = modulate(hm,data2);

            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            gp=1.2; phip=4*pi/180;
            k1p=k1'; k2p = k2';
            %signal=randn(N,1)+1i*randn(N,1);
            %image=randn(N,1)+1i*randn(N,1); 
            mix1=fft(k1*signal+k2*conj(image));
            mix2=fft(k1p*image+k2p*conj(signal));
            m1=mean(mix1);
            m2=mean(mix2);
            mix1=mix1-m1;
            mix2=mix2-m2;
            p1=mean(abs(mix1));
            mix1=mix1/p1;
            mix2=mix2/p1;       
            
            res=obj.effect([mix1(2:end) mix2(end:-1:2)]);
            
            %subplot(2,1,1); plot(db(abs(signal-p)))
            
            K=[[k1 k2];[k2p k1p]]
            Kp=[[obj.k1 obj.k2];[obj.k2p obj.k1p]]
            K./Kp
            
            M=16;
            hm = modem.qamdemod(M);
            
            rec1=ifft([m1;p1*res(:,1)+ m1]);
            scatterplot(rec1);
            scatterplot(ifft(mix1)*p1);
            data1r = demodulate(hm,rec1);
            data2r = demodulate(hm,ifft([m2;p2*res(end:-1:1,2)+ m2]));
            
            biterr(data1,data1r,log2(M))
            biterr(data2,data2r,log2(M))        
            
            
        end        
        function test0(obj)
            disp('This test case generates 16-QAM sequences, that are mixed');
            disp('in the presence of frequency flat I/Q mismatch');
            disp('g=1.2 phi=4 degrees');
            disp('The output of the test is the initial mixing matrix K');
            disp('and the estimated one.');
            N=10000;
            M=16;
            hm = modem.qammod(M);
            OverSample=10;
            
            data1=randi(M,N,1)-1;
            signal = modulate(hm,data1);
            data2=randi(M,N,1)-1;
            image = modulate(hm,data2);
            
            upsamplesignal=zeros(OverSample*length(signal),1);
            for ii=1:OverSample
                 upsamplesignal(ii:OverSample:end)=signal;
            end
            
            upsampleimage=zeros(OverSample*length(image),1);
            for ii=1:OverSample
                 upsampleimage(ii:OverSample:end)=image;
            end
            
            signal=awgn(upsamplesignal,100,'measured');
            image=awgn(upsampleimage,100,'measured');
            
            g=1.1; phi=3*pi/180;
            k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
            gp=1.2; phip=4*pi/180;
            k1p=(1+gp*exp(-1i*phip))/2; k2p = (1-gp*exp(1i*phip))/2;
            %signal=randn(N,1)+1i*randn(N,1);
            %image=randn(N,1)+1i*randn(N,1); 
            %signal=signal/mean(abs(signal));
            %image=signal/mean(abs(image));
            
            mix1=k1*signal+k2*conj(image);
            mix2=k1'*image+k2'*conj(signal);
       
            %res=obj.estimate(mix1,mix2); res=res.';
            res=obj.effect([mix1 mix2]); 
            
            scatterplot(res(:,1));
            scatterplot(mix1);
            
            K=[[k1 k2];[k2' k1']]
            Kp=[[obj.k1 obj.k2];conj([obj.k2 obj.k1])]

            downsampleres = res(1:OverSample:end,:);
            hm = modem.qamdemod(M);
            
            data1r = demodulate(hm,downsampleres(:,1));
            data2r = demodulate(hm,downsampleres(:,2));
            
            biterr(data1,data1r,log2(M))
            biterr(data2,data2r,log2(M))        
            
            
        end
    end
end
