function [S, distance] = get_random_sources(n_sources, distance_wall, distance_sources, ROOM)
%% GET_RANDOM_SOURCES provides random source positions within a specified 3-dimensional room
%
% Source positions can be constrained by a minimum required distance between sources and
% between a source and the wall, as well as the maximum _x_ and _y_ coordinates given by
% _ROOM_.
%
%% Caveats
% * Resolution of source locations is fixed to _0.1m_
% * Distance is checked on a per-coordinate basis. Actual minimum distance might therefore be
% slightly higher than specified
% * z-coordinate of all source locations is fixed to _1.0m_
%
%% TODO's
% * add z-coordinate parameter
% * add parameter to adjust grid resolution
% * use code from |estimation_error_rad.m| to check for eucledian distance
%
%% Arguments
% * *n_sources (int)*: number of sources _(default: *2*)_
% * *distance_wall*: minimum required distance between source and wall _(in decimetre, default: *12*)_
% * *distance_sources*: required minimum distance between sources _(in decimetre, default: *5*)_
% * *ROOM (mat)*: room dimensions _(2x1 matrix, default: *[6, 6]*)_

if nargin < 1, n_sources = 2; end
if nargin < 2, distance_wall = 12; end
if nargin < 3, distance_sources = 5; end
if nargin < 4, ROOM = [6 6]; end

%% Algorithm
% The algorithm arbitrarily choses source locations until a set of source locations is
% found that satisfies all requirements. While not very efficient, this was easy to
% implement and does the job! :)

x_done = false; y_done = false; i = 0;

while (x_done==false || y_done==false)
    
    % chose random coordinate value from set of all valid source locations
    x_rand = randi([0+distance_wall, ROOM(1)*10-distance_wall], n_sources, 1)./10;
    y_rand = randi([0+distance_wall, ROOM(2)*10-distance_wall], n_sources, 1)./10;
    i = i+1;

    % ensure distance_sources requirement
    if min(abs(diff(x_rand))) > distance_sources/10
        x_done = true;
    elseif min(abs(diff(y_rand))) > distance_sources/10
        y_done = true;
    end

    if n_sources==1, break; end
end

%% Output
S      = [x_rand y_rand ones(n_sources, 1)];
distance = min(abs(diff(x_rand)))+min(abs(diff(y_rand)));
fprintf('      -> done! (found %i sufficiently spaced sources (distance = %0.2f) after %i attempts)\n', n_sources, distance, i);

end
