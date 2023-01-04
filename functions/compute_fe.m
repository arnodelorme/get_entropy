% Calculates fuzzy entropy (FE) of a univariate signal x
%
% Inputs:
%   x   - univariate signal, a vector of size 1 x N (the number of sample points)
%   m   - embedding dimension (default = 2)
%   r   - threshold (usually 0.15 of the standard deviation of a signal. but since we normalize the data to have a sd of 1, r = 0.15)
%   n   - fuzzy power (usually 2)
%   tau - time lag (usually 1)
%
% Outputs:
%   fe  - scalar quantity - the FuzEn of x
%   p   - a vector of length 2 (the global quantity in dimension m, the
%           global quantity in dimension m+1)
%
%
% Based on:
%   [1] H. Azami and J. Escudero, "Refined Multiscale Fuzzy Entropy based on Standard Deviation for Biomedical Signal Analysis", 
%       Medical & Biological Engineering & Computing, 2016.
%   [2] W. Chen, Z. Wang, H. Xie, and W. Yu,"Characterization of surface EMG signal based on fuzzy entropy", 
%       IEEE Transactions on neural systems and rehabilitation engineering, vol. 15, no. 2, pp.266-272, 2007.
% 
% Cedric Cannard

function [fe, p] = compute_fe(x,m,r,n,tau)

if ~exist('m','var'), m = 2; end
if ~exist('r','var'), r = .15; end
if ~exist('n','var'), n = 2; end
if ~exist('tau','var'), tau = 1; end

if tau > 1, x = downsample(x, tau); end

N = length(x);
p = zeros(1,2);
xMat = zeros(m+1,N-m);
parfor i = 1:m+1
    xMat(i,:) = x(i:N-m+i-1);
end

for k = m:m+1
    count = zeros(1,N-m);
    tmp = xMat(1:k,:);
    
    parfor i = 1:N-k

        % calculate Chebyshev distance without counting self-matches
        dist = max(abs(tmp(:,i+1:N-m) - repmat(tmp(:,i),1,N-m-i)));
        df = exp((-dist.^n)/r);
        count(i) = sum(df)/(N-m);
    end
    
    p(k-m+1) = sum(count)/(N-m);
end

fe = log(p(1)/p(2));
end
