function [fig_room, DOA] = plot_room(ROOM, R, S)
%PLOT_ROOM creates a room to simulate signals at audio receivers from multiple sources

%CONSTANTS
ROOM_FIXPOINT = 0;
ROOM_BORDER = 1;
ROOM_WIDTH = ROOM(1);
ROOM_HEIGHT = ROOM(2);
ROOM_TEXT_OFFSET_X = 0.15;
ROOM_TEXT_OFFSET_Y = 0.15;
PLOT_ELEM_SIZE = 14;
PLOT_BORDER = .05;

n_receivers = size(R, 1);
n_sources = size(S, 1);

fig_size = [1600 800];  % width x height
scr_size = get(0,'ScreenSize');
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically

fig_room = figure('Name','Simulated Environment',...
                  'NumberTitle','off',...
                  'Color','white',...
                  'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)],...
                  'MenuBar','none');
% movegui(fig_room,'center')  % alternative to have figure in the middle of the screen
subplot_tight(2,2,[1 3], PLOT_BORDER);
hold on;
title('Room')

% plot room rectangle and surroundings
rectangle('Position',[ROOM_FIXPOINT;ROOM_FIXPOINT;ROOM_WIDTH;ROOM_HEIGHT]);
plot(ROOM_FIXPOINT - ROOM_BORDER, ROOM_FIXPOINT - ROOM_BORDER, '.', 'Color', 'w')
plot(ROOM_WIDTH + ROOM_BORDER, ROOM_HEIGHT + ROOM_BORDER, '.', 'Color', 'w')

% calculate connecting lines between sources and receivers
rs_connection = zeros(n_receivers, n_sources, 2, 100);
for r = 1:n_receivers
    for s = 1:n_sources
        for dim = 1:2
            rs_connection(r, s, dim, :) = linspace(S(s,dim), R(r,dim), 100);
        end
    end
end

% plot receivers, sources and their connecting lines
for r = 1:n_receivers
    plot(R(r,1), R(r,2), 'O', 'MarkerSize', PLOT_ELEM_SIZE, 'Color', 'b')
end
for s = 1:n_sources
    plot(S(s,1), S(s,2), 'X', 'MarkerSize', PLOT_ELEM_SIZE, 'Color', 'r')
    text(S(s,1)+ROOM_TEXT_OFFSET_X, S(s,2)+ROOM_TEXT_OFFSET_Y, strcat('s_{',int2str(s),'}'), 'Interpreter', 'tex', 'FontSize', 14, 'Color', 'r')
end

% for r = 1:n_receivers
%     for s = 1:n_sources
%         plot(squeeze(rs_connection(r, s, 1, :)), squeeze(rs_connection(r, s, 2, :)), 'Color', [0.8, 0.8, 0.8], 'LineStyle', '--')
%     end
% end

axis([-ROOM_BORDER,ROOM_WIDTH+ROOM_BORDER,-ROOM_BORDER,ROOM_HEIGHT+ROOM_BORDER]);

end