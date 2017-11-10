function S = get_random_sources(n_sources, distance_wall, distance_sources, ROOM)
% provides random source positions within a specified 3-dimensional room
%
% n_sources = number of sources (int)
% distance_wall = distance from wall [decimeter] (default: 12)
% distance_sources = required distance of source from each other (in both x and y
% direction) [decimeter] (default: 5)

if nargin < 2, distance_wall = 12; end
if nargin < 3, distance_sources = 5; end

x_done = false; y_done = false; i = 0;

    while (x_done==false || y_done==false)

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

    S      = [x_rand y_rand ones(n_sources, 1)];
    distance = min(abs(diff(x_rand)))+min(abs(diff(y_rand)));
    fprintf('      -> done! (found %i sufficiently spaced sources (distance = %0.2f) after %i attempts)\n', n_sources, distance, i);

end
