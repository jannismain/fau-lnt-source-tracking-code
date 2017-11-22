function [ prob ] = psi_quart( dim1, dim2, dim3, alt)
%PSI_HALF_HALF Generates initial psi matrix according to Schwartz2014
%   ARG:      dimX:	size of dimensions of the returned probability matrix (int)
%   ARG:       alt: alternate quarters (bool, default: true)
%
%   NOTE: floor() and ceil() is necessary, when either dim2 or dim3 is uneven.
%   NOTE: When dim2 or dim3 is uneven, resulting probabilities will overlapp by 1

if nargin<4, alt=true; end

altidx=0;

psi = rand(dim1, ceil(dim2/2), ceil(dim3/2));
prob = zeros(dim1, dim2, dim3);
for d=1:dim1
    quart = squeeze(psi(d,:,:))./sum(sum(squeeze(psi(d,:,:))));
    prob(d,1:ceil(dim2/2),1:ceil(dim3/2)) = quart;
    prob(d,:,:) = rot90(squeeze(prob(d,:,:)),altidx);
    if alt && altidx<3, altidx=altidx+1; else, altidx=0; end
end
