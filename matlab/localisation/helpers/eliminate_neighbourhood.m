function [ psi ] = eliminate_neighbourhood( psi, x, y, d )
%ELIMINATE_NEIGHBOURHOOD Set values of psi to zero for rectangle around [x,y] with length 2*d

%% Description
% Set values of psi to zero for rectangle around [x,y] with length 2*d

%% Arguments
% * *psi (mat)*: _Output of |<em_algorithm.html em_iterations.m>|_
% * *x (int)*: _x coordinate index of psi to eliminate area around_
% * *y (int)*: _y coordinate index of psi to eliminate area around_
% * *d (int)*: _half of length of rectangle that will be eliminated from |psi|_

%% Returns
% * *psi (mat)*: _Version of input argument |psi|, where rectangle was set to zero_

%% Determine Corners of Rectangle
% Rectangle defined by midpoint |[x y]| and length |d|. Actual side length of rectangle is
% d*2+1!
xmax = size(psi, 2);
ymax = size(psi, 1);
if x+d > xmax, x_top = xmax; else, x_top = x+d; end
if x-d <    1, x_bot =    1; else, x_bot = x-d; end
if y+d > ymax, y_top = ymax; else, y_top = y+d; end
if y-d <    1, y_bot =    1; else, y_bot = y-d; end

%% Set Values to 0
psi(y_bot:y_top,x_bot:x_top) = 0;
fprintf('      -> Eliminated psi from x=%d, y=%d to x=%d, y=%d\n', x_bot, y_bot, x_top, y_top)
end

