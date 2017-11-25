function [ prob ] = psi_schwartz2014( dim1, dim2, dim3, direction )
%PSI_HALF_HALF_E Summary of this function goes here
%   Detailed explanation goes here

if nargin<4, direction='v'; end

prob = zeros(dim1, dim2, dim3);
for d=1:dim1
    if mod(d,2)==0
        half = ones(dim2,ceil(dim3/2)) ./ (dim2*ceil(dim3/2));
        prob(d,:,1:ceil(dim3/2)) = half;
        if strcmp(direction, 'v')
            prob(d,:,:) = rot90(squeeze(prob(d,:,:)),2);
        else
            prob(d,:,:) = rot90(squeeze(prob(d,:,:)),1);
        end
    else
        half = ones(dim2,floor(dim3/2)) ./ (dim2*floor(dim3/2));
        prob(d,:,1:floor(dim3/2)) = half;
        if ~strcmp(direction, 'v')
            prob(d,:,:) = rot90(squeeze(prob(d,:,:)), 3);
        end
    end
end

end

