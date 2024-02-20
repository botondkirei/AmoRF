function [y,w_est] = IQCircBlock(x,Nw)

% Estimation of receiver I/Q imbalance compensator coefficients by utilizing
% the second-order statistics of the received imbalanced signal x.
% 
% INPUTS:
% Nw - Compensator filter length (practical values 1-10)
% x  - The mismatched baseband signal.
%      It is assumed that any possible DC-offsets have been removed from x. 
% OUTPUTS:
% y  - IQ-compensated signal
% w_est - Estimated compensator filter
%
% Original version by Lauri Anttila, 21.5.2007

x = x(:);  % make x a column vector
L = length(x);  % length of the signal vector

% Calculating the autocorrelation and the complementary autocorrelation 
% vectors that are needed for the block estimator:
% ---------------------------------------------------------------------
% % using the Matlab function xcorr:
% r_x0 = xcorr(x,'biased');
% c_x0 = xcorr(x,conj(x),'biased');
% r_x = r_x0(L:L+(2*Nw-2));
% c_x = c_x0(L:L+(2*Nw-2));
% r_x = r_x(:);
% c_x = c_x(:);

% Alternative (equivalent) way of forming the correlation vectors:
for k = 1:2*Nw-1,
    r_x(k,1) = 1/L*sum(x(k:end).*conj(x(1:end-k+1)));  % autocorrelation
    c_x(k,1) = 1/L*sum(x(k:end).*x(1:end-k+1));        % complementary correlation
end
r_x_long = [conj(flipud(r_x(2:end))) ; r_x];
c_x_long = [flipud(c_x(2:end)) ; c_x];


% Forming the correlation matrices:
% ---------------------------------

% Rx = toeplitz(r_x(1:Nw).');
%  or alternatively
for k = 1:Nw,
    Rx(k,:) = r_x_long(2*Nw-k:3*Nw-k-1).';
end

% Rx2 = fliplr(toeplitz(r_x(Nw:2*Nw-1),fliplr(r_x(1:Nw).')));
%  or alternatively
for k = 1:Nw,
    Rx2(k,:)=r_x(k:k+Nw-1).';
end

% Cx = toeplitz(c_x(1:2*Nw-1).',c_x(1:Nw)); % non-square toeplitz
%  or alternatively
for k = 1:Nw,
    Cx(:,k) = c_x_long(2*Nw-k:4*Nw-k-2);
end

% APPROXIMATE SOLUTION of the compensator filter:
w_est = -inv(Rx+Rx2)*c_x(1:Nw); % The closed-form approximation which
                                % ignores the term W*conj(Cx)*w

% EXACT SOLUTION of the compensator filter:
% Iteration to obtain the w which exactly nulls the complementary correlation
% of the compensator output:
Niter = 10;
w = zeros(Nw,Niter);
W = zeros(Nw,2*Nw-1);
for k = 1:Niter-1,
    w(:,k+1) = -inv(Rx + Rx2 + W*conj(Cx))*c_x(1:Nw);
    W = convmtx(w(:,k+1),Nw).';
end
w_est = w(:,end);

% I/Q imbalance compensation:
image_est = filter(w_est,1,conj(x));  % estimate of the (negative of the) image signal
y = x + image_est(1:L);  % compensated signal

return

% Frequency responses of the desired and the conjugate signal component,
% and the total IRR of the compensated signal (with the approximate solution,
% and assuming that the imbalance filters g1 and g2 are known):
tot = ([g1 zeros(1,Nw-1)] + conv(w_est.',conj(g2))); % total impulse response of the desired component
tot_conj = ([g2 zeros(1,Nw-1)] + conv(w_est.',conj(g1)));  % total impulse response of the image component
T1 = fft(tot,256);  % frequency responses
T2 = fft(tot_conj,256);
IRR_comp = 20*log10(abs(fftshift(T1))./abs(fftshift(T2))); % IRR vs. frequency

% FIR equalizer to remove the excess ISI from the compensated 
% signal as y_eq = filter(equ_fir,1,y). Only needed if the 
% frequency-selectivity of the I/Q imbalances is severe.
equ_fir = impz(1,tot); 
