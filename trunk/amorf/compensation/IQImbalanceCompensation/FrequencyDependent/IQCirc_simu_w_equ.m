% Simple demonstration of the circularity-based receiver I/Q imbalance
% compensator algorithms with a single QAM signal

clear all
close all

Nw = 3;
Nsym = 100000;

SNR_dB = 40;
SNR = 10^(SNR_dB/10);

g = 1.2;  % gain imbalance
phi = 10/180*pi;  % phase imbalance
d = [0.01 -0.02 -0.01].';  % impulse response imbalance
h = [1 0 0].' + d;

g1 = 0.5*([1 0 0].' + h*g*exp(-1i*phi));  % IQ imbalance filters
g2 = 0.5*([1 0 0].' - h*g*exp(+1i*phi));

G1 = fft(g1,256);
G2 = fft(g2,256);

IRR_FE = 20*log10(abs(G1)./abs(G2));  % front-end image rejection ratio

% Ideal compensator
wOPT = -G2./conj([G1(1); flipud(G1(2:end))]);
w_opt = ifft(wOPT);
w_opt = w_opt(1:5)

a = -3:2:3; 
A = repmat(a,4,1);
B = flipud(A');
alphabet = A(:) + 1i*B(:); % 16-QAM alphabet
sym = alphabet(randint(Nsym,1,length(alphabet))+1);  % symbol sequence

noise = sqrt(mean(abs(sym).^2))/sqrt(2*SNR)*(randn(size(sym)) + 1i*randn(size(sym)));

% % Check SNR:
% SNR_real = mean(abs(sym).^2)/mean(abs(noise).^2)

z = sym + noise;

x = conv(g1,z) + conv(g2,conj(z));

[y_bl,w_bl] = IQCircBlock(x,Nw);
[y_it,w_it] = IQCircIter(x,Nw,0.4e-4);

tot = ([g1; zeros(Nw-1,1)] + conv(w_bl,conj(g2))); % total impulse response of the desired component
% equ_fir = impz(1,tot);

y_bl_equ = filter(1,tot,y_bl);
y_it_equ = filter(1,tot,y_it);

figure,subplot(2,2,1),plot(z(1:Nsym),'x'),axis([-5 5 -5 5]),axis square,title('z')
hold,subplot(2,2,2),plot(x(1:Nsym),'x'),axis([-5 5 -5 5]),axis square,title('x')
subplot(2,2,3),plot(y_bl_equ(1:Nsym),'x'),axis([-5 5 -5 5]),axis square,title('y_{bl}')
subplot(2,2,4),plot(y_it_equ(1:Nsym),'x'),axis([-5 5 -5 5]),axis square,title('y_{it}')
