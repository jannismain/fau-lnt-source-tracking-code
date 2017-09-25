function [src_traj] = get_trajectory(x, y, z, samples, movement)
%get_trajectory  Creates a 3-dimensional trajectory vector
%
% [src_traj] = get_trajectory()  
%
% This function generates a trajectory vector based on the input arguments
% x, y and z. The input arguments corresponds to the planes of a cartesian 
% coordinate system. When the argument is provided as scalar, it simply 
% generates a constant vector. When the argument is provided as vector, it
% uses linspace() to create a smooth trajectory from point A to point B in
% this plane.

%% handling optional argument 'movement'
if not(nargin > 3 && exist('movement','var') && ~(ischar(movement))), movement = [0 0 0]; end

%% handling optional argument 'samples'
if not(nargin > 3 && exist('samples','var') && ~(ischar(samples)))
    samples = max(abs(movement))*100+1;  % will generate 100 samples per meter
end

%% handling required arguments x, y, z
if nargin < 3, error("This function requires 3 input arguments x, y, z."), return, end

%% x
if size(x,2)==2
    fprintf("      -> x is VECTOR ([%d %d])\n", x(1), x(2));
    src_x_trajectory = linspace(x(1),x(2),samples).';
elseif movement(1) ~= 0
    fprintf("      -> x is VECTOR ([%d %d], moves by %d)\n", x, x+movement(1), movement(1));
    src_x_trajectory = linspace(x,x+movement(1),samples).';
elseif size(x,2)==1
    fprintf("      -> x is SCALAR (%d)\n", x);
    src_x_trajectory = ones(samples,1)*x;
else
    error("Argument 'x' has to be either 1- or 2-dimensional!\n")
end
%% y
if size(y,2)==2
    fprintf("      -> y is VECTOR ([%d %d])\n", y(1), y(2));
    src_y_trajectory = linspace(y(1),y(2),samples).';
elseif movement(2) ~= 0
    fprintf("      -> y is VECTOR ([%d %d], moves by %d)\n", y, y+movement(2), movement(2));
    src_y_trajectory = linspace(y,y+movement(2),samples).';
elseif size(y,2)==1
    fprintf("      -> y is SCALAR (%d)\n", y);
    src_y_trajectory = ones(samples,1)*y;
else
    error("Argument 'y' has to be either 1- or 2-dimensional!\n")
end
%% z
if size(z,2)==2
    fprintf("      -> z is VECTOR ([%d %d])\n", z(1), z(2));
    src_z_trajectory = linspace(z(1),z(2),samples).';
elseif movement(3) ~=0
    fprintf("      -> z is VECTOR ([%d %d], moves by %d)\n", z, z+movement(3), movement(3));
    src_z_trajectory = linspace(z,z+movement(3),samples).';
elseif size(z,2)==1
    fprintf("      -> z is SCALAR (%d)\n", z);
    src_z_trajectory = ones(samples,1)*z;
else
    error("Argument 'z' has to be either 1- or 2-dimensional!\n")
end

%% setting return value
src_traj = [src_x_trajectory src_y_trajectory src_z_trajectory];

end