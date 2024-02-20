%initializations

N=30000;
g=1.2; phi=2*pi/180;
k1=(1+g*exp(-1i*phi))/2; k2 = (1-g*exp(1i*phi))/2;
gp=1.2; phip=4*pi/180;
k1p=(1+gp*exp(-1i*phip))/2; k2p = (1-gp*exp(1i*phip))/2;
signal=randn(N,1)+1i*randn(N,1);
image=randn(N,1)+1i*randn(N,1);

Kd=[[k1 k2];[k2p k1p]];
mix1=k1*signal+k2*conj(image);
mix2=k1p*image+k2p*conj(signal);
%normalize the signals
mix1=mix1/(mean(abs(mix1)));
mix2=mix2/(mean(abs(mix2)));

K=Kd;
mu=0.001;
cold=eye(2);
for i=1:1000
    W=inv(K);
    x=W*[mix1.';mix2'];
    covar=mean(x(1,:).*conj(x(2,:)));
    d=det(K);
    e11=covar*(-K(2,1)*(K(2,2)^2)*d^2-K(1,2)*d-K(1,2)*K(1,1)*d^2);
    e12=covar*(K(2,2)*K(2,1)^2*d^2-K(1,1)*d+K(1,1)*K(1,2)*K(2,1)*d^2);
    e21=covar*(-K(2,2)*d+K(2,2)*K(2,1)*K(1,2)*d^2+K(1,1)*K(1,2)^2*K(1,1)*d^2);
    e22=covar*(-K(1,2)*K(1,1)^2*d^2-K(2,1)*K(2,2)*K(1,1)*d^2+K(2,1)*d);
    E=[[sign(real(e11))+1i*sign(imag(e11)) sign(real(e12))+1i*sign(imag(e12))]...
        ;[sign(real(e21))+1i*sign(imag(e21)) sign(real(e22))+1i*sign(imag(e22))]];
    E=[[e11 e12];[e21 e22]];
    K=K-mu*E;
    %K=[[conj(1-K(1,2)) K(1,2)];[K(2,1) conj(1-K(2,1))]];
end
K
Kd
    

