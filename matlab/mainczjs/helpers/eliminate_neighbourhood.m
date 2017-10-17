function [ psi ] = eliminate_neighbourhood( psi, x, y, d )
%ELIMINATE_NEIGHBOURHOOD Summary of this function goes here
%   Detailed explanation goes here

xmax = size(psi, 2);
ymax = size(psi, 1);
if x+d > xmax, x_top = xmax; else, x_top = x+d; end
if x-d <    1, x_bot =    1; else, x_bot = x-d; end
if y+d > ymax, y_top = ymax; else, y_top = y+d; end
if y-d <    1, y_bot =    1; else, y_bot = y-d; end

%% Quick elimination strategy
try
    psi(y_bot:y_top,x_bot:x_top) = 0;
    fprintf('Eliminated psi from x=%d, y=%d to x=%d, y=%d\n', x_bot, y_bot, x_top, y_top)
    return
catch
    fprintf('Quick elimination failed! Will eliminate one by one! (x=%d, y=%d, psi=%dx%d, d=%d)\n', x, y, size(psi, 1), size(psi, 2), d)
end

%% Fine elimination strategy
% for dx=1:d
%     for dy=1:d
%         if y+dy<size(psi, 1) && x+dx<size(psi, 2)
%             psi(y+dy,x+dx) = 0;
%         catch
%             fprintf("%dx%d could not be removed!", d+dy, x+dx);
%         end
%         try
%             psi(y+dy,x-dx) = 0;
%         catch
%             fprintf("%dx%d could not be removed!", d+dy, x+dx);
%         end
%         try
%             psi(y-dy,x+dx) = 0;
%         catch
%             fprintf("%dx%d could not be removed!", d+dy, x+dx);
%         end
%         try
%             psi(y-dy,x-dx) = 0;
%         catch
%             fprintf("%dx%d could not be removed!", d+dy, x+dx);
%         end
%     end
end

