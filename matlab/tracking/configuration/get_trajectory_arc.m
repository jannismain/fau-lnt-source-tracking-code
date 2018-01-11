function [ traj ] = get_trajectory_arc( startpos, endpos, radius, samples, alt)
%GET_TRAJECTORY_ARC Create source trajectory that follows an arc

%% Description
% Create source trajectory that follows an arc.
%
% The arc is described by its start position, end position and its radius. As this still
% leaves two possible arcs, the |alt| parameter fully determines the arc.

%% Arguments
% * *startpos (double)*: _coordinate of start position of the trajectory_
% * *endpos (double)*: _coordinate of end position of the trajectory_
% * *radius (double)*: _radius of the trajectory arc_
% * *startpos (double)*: _coordinate of start position of the trajectory_
% * *samples (int)*: _number of samples simulated across trajectory_
% * *alt (bool)*: _create alternative arc_

%% Initialisation
d = sqrt((endpos(1)-startpos(1))^2+(endpos(2)-startpos(2))^2); % Distance between points
if alt
    a = atan2(endpos(1)-startpos(1),-(endpos(2)-startpos(2)));
else
    a = atan2(-(endpos(1)-startpos(1)),endpos(2)-startpos(2)); % Perpendicular bisector angle
end
b = asin(d/2/radius); % Half arc angle
c = linspace(a-b,a+b, samples)'; % Arc angle range
e = sqrt(radius^2-d^2/4); % Distance, center to midpoint

%% Compute Arc
x = (startpos(1)+endpos(1))/2-e*cos(a)+radius*cos(c); % Cartesian coords. of arc
y = (startpos(2)+endpos(2))/2-e*sin(a)+radius*sin(c);

%% Sample Arc to Create Trajectory
traj = [x y ones(samples, 1)*startpos(3)];

end

