function [src_traj] = get_trajectory_from_source(source, movement, samples)
%get_trajectory  Creates a 3-dimensional trajectory vector
%
% [src_traj] = get_trajectory(source, movement, samples)  
%
% This function generates a trajectory vector based on the input arguments
% source and movement. 'source' is assumed to be an absolute, 3-dimensional
% cartesian coordinate pair, whereas 'movement' describes a relative
% change in position in all three planes.

%% handling optional argument 'samples'
if nargin > 2 && exist('samples','var') && ~(ischar(samples))
    src_samples = samples;
else
    src_samples = max(abs(movement))*100+1;  % will generate 100 samples per meter
    fprintf("...%d samples per vector\n", src_samples);
end

src_traj = zeros(length(source), src_samples).';
%% handling required arguments x, y, z
if not(nargin < 2)
    for n=1:3
        src_traj(:,n) = linspace(source(n),source(n)+movement(n),src_samples).';
    end
else
    error("This function requires at least 2 input arguments 'source'  and 'movement'.")
end
end
