function [ traj ] = get_trajectory_arc( startpos, endpos, radius, samples, mirror)
%GET_TRAJECTORY_ARC Summary of this function goes here
%   Detailed explanation goes here
% 

% helpers
d = sqrt((endpos(1)-startpos(1))^2+(endpos(2)-startpos(2))^2); % Distance between points
if mirror
    a = atan2(endpos(1)-startpos(1),-(endpos(2)-startpos(2)));
else
    a = atan2(-(endpos(1)-startpos(1)),endpos(2)-startpos(2)); % Perpendicular bisector angle
end
b = asin(d/2/radius); % Half arc angle
c = linspace(a-b,a+b, samples)'; % Arc angle range
e = sqrt(radius^2-d^2/4); % Distance, center to midpoint

x = (startpos(1)+endpos(1))/2-e*cos(a)+radius*cos(c); % Cartesian coords. of arc
y = (startpos(2)+endpos(2))/2-e*sin(a)+radius*sin(c);

traj = [x y ones(samples, 1)*startpos(3)];

end

