function [ psi ] = psi_random( dim1, dim2, dim3 )
%GET_RANDOM_PROBABILITY_DISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

psi = rand(dim1, dim2, dim3);
for d=1:dim1
    psi(d,:,:) = squeeze(psi(d,:,:))./sum(sum(squeeze(psi(d, :, :))));
end

end

