function [y,w_ss] = IQCircIter(x,Nw,mu)

% Estimation of receiver I/Q imbalance compensator coefficients by utilizing
% the second-order statistics of the received imbalanced signal x.
% Implementation based on adaptive filtering.
% 
% INPUTS:
% Nw - Compensator filter length (practical values 1-10)
% x  - The mismatched baseband signal.
%      It is assumed that any possible DC-offsets have been removed from x. 
% mu - relative step-size of the iterative algorithm 
%        (choose between 1e-6 and 1e-3, roughly)
% OUTPUTS:
% y  - IQ-compensated signal
% w  - Compensator filter convergence curve - the last column is used in the
%      compensation.
%
% Original version by Lauri Anttila, 21.5.2007

x = x(:);  % make x a column vector
L = length(x);  % length of the signal vector

Niter = L;  % number of iterations
Px = mean(abs(x).^2);  % Power of x
lambda = mu/Px;  % absolute step-size
lambda2 = kron(ones(Nw,1),lambda);  % [lambda; lambda; lambda];
w = zeros(Nw,Niter);  % initialize the compensator filter
y = zeros(size(x));   % initialize the output signal

for t = Nw:Niter-1,

    y(t) = x(t) + w(:,t).'*conj(x(t:-1:t-Nw+1));
    w(:,t+1) = w(:,t) - lambda2.*[y(t:-1:t-Nw+1)]*y(t);

end

w_ss = w(:,t+1); % final (steady-state) compensator filter

% I/Q imbalance compensation with the steady-state filter:
image_est = filter(w_ss,1,conj(x)); % estimate of the (negative of the) image signal
y = x + image_est(1:L);  % compensated signal

return

% Frequency responses of the desired and the conjugate signal component,
% and the total IRR of the compensated signal (assuming that the imbalance 
% filters g1 and g2 are known):
tot = ([g1 zeros(1,Nw-1)] + conv(w_ss.',conj(g2))); % total impulse response of the desired component
tot_conj = ([g2 zeros(1,Nw-1)] + conv(w_ss.',conj(g1)));  % total impulse response of the image component
T1 = fft(tot,256);  % frequency responses
T2 = fft(tot_conj,256);
IRR_comp = 20*log10(abs(fftshift(T1))./abs(fftshift(T2))); % IRR vs. frequency

% FIR equalizer to remove the excess ISI from the compensated 
% signal as y_eq = filter(equ_fir,1,y). Only needed if the 
% frequency-selectivity of the I/Q imbalances is severe.
equ_fir = impz(1,tot); 
