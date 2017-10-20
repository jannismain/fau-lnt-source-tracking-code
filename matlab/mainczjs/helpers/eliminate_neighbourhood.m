function [ psi ] = eliminate_neighbourhood( psi, x, y, d )
%ELIMINATE_NEIGHBOURHOOD Summary of this function goes here
%   Detailed explanation goes here

% Ensure, that indices stay within size(psi)
xmax = size(psi, 2);
ymax = size(psi, 1);
if x+d > xmax, x_top = xmax; else, x_top = x+d; end
if x-d <    1, x_bot =    1; else, x_bot = x-d; end
if y+d > ymax, y_top = ymax; else, y_top = y+d; end
if y-d <    1, y_bot =    1; else, y_bot = y-d; end

psi(y_bot:y_top,x_bot:x_top) = 0;
% fprintf('      -> Eliminated psi from x=%d, y=%d to x=%d, y=%d\n', x_bot, y_bot, x_top, y_top)
end

