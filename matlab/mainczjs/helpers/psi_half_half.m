function [ prob ] = psi_half_half( dim1, dim2, dim3, alt,direction)
%PSI_HALF_HALF Generates initial psi matrix according to Schwartz2014
%   ARG:      dimX:	size of dimensions of the returned probability matrix (int)
%   ARG:       alt: alternating sides per dim1 (bool)
%   ARG: direction:	direction of seperation (str; 'horz' or 'vert')
%
%   NOTE: floor() and ceil() is necessary, when either dim2 or dim3 is uneven.

if nargin<4, alt=true; end
if nargin<5, direction='horz'; end

if alt, mirror=false; end

if strcmp(direction, 'vert')
    psi = rand(dim1, dim2, ceil(dim3/2));
    prob = zeros(dim1, dim2, dim3);
    for d=1:dim1
        half = squeeze(psi(d,:,:))./sum(sum(squeeze(psi(d,:,:))));
        prob(d,:,1:ceil(dim3/2)) = half;
        if alt
            if mirror
                prob(d,:,:) = fliplr(squeeze(prob(d,:,:)));
            end
            mirror = ~mirror;
        end
    end

elseif strcmp(direction, 'horz')
    psi = rand(dim1, ceil(dim2/2), dim3);
    prob = zeros(dim1, dim2, dim3);
    for d=1:dim1
        half = squeeze(psi(d,:,:))./sum(sum(squeeze(psi(d,:,:))));
        prob(d,1:ceil(dim2/2),:) = half;
        if alt
            if mirror
                prob(d,:,:) = flipud(squeeze(prob(d,:,:)));
            end
            mirror = ~mirror;
        end
    end
end

