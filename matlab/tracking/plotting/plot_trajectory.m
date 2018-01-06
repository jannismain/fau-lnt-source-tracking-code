function [ fig ] = plot_trajectory( traj, m, fig)
%PLOT_TRAJECTORY Summary of this function goes here
%   Detailed explanation goes here

if nargin<2, m = 'x'; end
if nargin<3, fig = figure(); end
n_sources = size(traj, 1);
n_samples = size(traj, 2);
if size(traj, 3) > 3, err("'traj' must be of shape [ n_sources x n_samples x 2/3]!"); end
if size(traj, 3) == 3, traj = traj(:,:,1:2); end
if size(traj, 3) == 1, temp = traj; traj = zeros(1,size(temp,1),size(temp,2)); traj(1, :, :) = temp; end
hold on;

for s=1:size(traj, 1)
    % Define colormap
    colorCode = jet(size(traj,2));
    ax = scatter(squeeze(traj(s,:,1)),squeeze(traj(s,:,2)),64,colormap(colorCode),m);
    if m=='x'
        set(ax,'SizeData',256)
    end
    
end
end
