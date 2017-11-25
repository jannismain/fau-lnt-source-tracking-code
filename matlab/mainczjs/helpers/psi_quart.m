function [ prob ] = psi_quart( dim1, dim2, dim3, alt, rnd)
%PSI_HALF_HALF Generates initial psi matrix according to Schwartz2014
%   ARG:      dimX:	size of dimensions of the returned probability matrix (int)
%   ARG:       alt: alternate quarters (bool, default: true)
%
%   NOTE: floor() and ceil() is necessary, when either dim2 or dim3 is uneven.
%   NOTE: When dim2 or dim3 is uneven, resulting probabilities will overlapp by 1

if nargin<4, alt=true; end
if nargin<5, rnd=true; end

altidx=1;
if rnd
    psi = rand(dim1, ceil(dim2/2), ceil(dim3/2));
else
    psi = ones(dim1, ceil(dim2/2), ceil(dim3/2));
end
prob = zeros(dim1, dim2, dim3);
for d=1:dim1
    if mod(altidx, 3)==0 
        quart = squeeze(psi(d,1:end-1,1:end-1))./sum(sum(squeeze(psi(d,1:end-1,1:end-1))));
        prob(d,1:floor(dim2/2),1:floor(dim3/2)) = quart;
    elseif mod(altidx, 2)==0 && mod(altidx, 4)~=0
        quart = squeeze(psi(d,:,1:end-1))./sum(sum(squeeze(psi(d,:,1:end-1))));
        prob(d,1:ceil(dim2/2),1:floor(dim3/2)) = quart;
    elseif mod(altidx, 4)==0
        quart = squeeze(psi(d,1:end-1,:))./sum(sum(squeeze(psi(d,1:end-1,:))));
        prob(d,1:floor(dim2/2),1:ceil(dim3/2)) = quart;
    else  %altidx=1
        quart = squeeze(psi(d,:,:))./sum(sum(squeeze(psi(d,:,:))));
        prob(d,1:ceil(dim2/2),1:ceil(dim3/2)) = quart;
    end
    prob(d,:,:) = rot90(squeeze(prob(d,:,:)),altidx-1);
    if alt && altidx<4, altidx=altidx+1; else, altidx=1; end
end
