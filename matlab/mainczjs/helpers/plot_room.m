function [fig, ax_s, ax_r] = plot_room(ROOM, R, S, subplots, height, width, fig, varargin)
%PLOT_ROOM creates a room to simulate signals at audio receivers from multiple sources

if nargin<4, subplots=2; end
if nargin<5, width=subplots*800; height=800; end
if nargin<7, fig_supplied=false;else,fig_supplied=true;end

%CONSTANTS
ROOM_FIXPOINT = 0;
ROOM_BORDER = 0;
ROOM_WIDTH = ROOM(1);
ROOM_HEIGHT = ROOM(2);
ROOM_TEXT_OFFSET_X = 0.15;
ROOM_TEXT_OFFSET_Y = 0.15;
PLOT_ELEM_SIZE = 14;
PLOT_BORDER = .05;

n_receivers = size(R, 1);
n_sources = size(S, 1);

fig_size = [width height];  % width x height
scr_size = get(0,'ScreenSize');
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically

if ~fig_supplied
    fig = figure('Name','Simulation Setup',...
                  'NumberTitle','off',...
                  'Color','white',...
                  'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)],...
                  'MenuBar','none');
end
if subplots > 1, subplot_tight(1,subplots,1, PLOT_BORDER);end

% plot room rectangle and surroundings
% rectangle('Position',[ROOM_FIXPOINT;ROOM_FIXPOINT;ROOM_WIDTH;ROOM_HEIGHT]);
if ROOM_BORDER > 0
    plot(ROOM_FIXPOINT - ROOM_BORDER, ROOM_FIXPOINT - ROOM_BORDER, '.', 'Color', 'w')
    plot(ROOM_WIDTH + ROOM_BORDER, ROOM_HEIGHT + ROOM_BORDER, '.', 'Color', 'w')
end

% plot receivers and sources
hold on;
ax_bg = surf(linspace(0,ROOM(1),ROOM(1)),linspace(0,ROOM(2), ROOM(2)), zeros(ROOM(1), ROOM(2)));
colormap([61/255 38/255 168/255]);
ax_r = plot(R(:, 1), R(:, 2),'O','MarkerSize', 8, 'Linewidth',1,'Color','g');    
ax_s = plot(S(:, 1), S(:, 2),'x','MarkerSize', 12, 'Linewidth',1,'Color','r');
hold off;
shading interp;
% legend show;

legend([ax_bg, ax_s, ax_r], 'room', 'source', 'receiver');
% legend('Location','NorthEastOutside')

axis([-ROOM_BORDER,ROOM_WIDTH+ROOM_BORDER,-ROOM_BORDER,ROOM_HEIGHT+ROOM_BORDER]);

end