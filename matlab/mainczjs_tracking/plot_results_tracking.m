function [] = plot_results_tracking( loc_est, sources, room )
%PLOT_RESULTS_TRACKING Summary of this function goes here
%   Detailed explanation goes here
% load('config.mat');

% Create Figure in the middle of the screen with a reasonable size
scr_size = get(0,'ScreenSize');
fig_size = [750 600];  % width x height
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
fig = figure('Name','Location Estimate Result',...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)]);%,...
              %'Visible','off');  TODO: Comment this back in for trial runs!
    
% plot sources
plot_trajectory(sources.trajectories, 'o', fig)

% plot estimates
plot_trajectory(loc_est, 'x', fig);

% plot room           
ax = gca;
ax.Color = 'white';
ax.XLim = [0,room.dimensions(1)];
ax.YLim = [0,room.dimensions(2)];
grid on
end