function [fig] = plot_loc_est_history_c(loc_est_history, sources, fig)

if nargin<3, fig = figure('Name','Coordinates across Iterations'); end

T = size(loc_est_history, 2);
traj = zeros(sources.n, T,3);
for s=1:sources.n
    traj(s,:,:) = get_trajectory_from_source(squeeze(sources.p(s,:)),squeeze(sources.movement(s,:)), T);
end
ax = subplot_tight(1,sources.n,1); hold on;
title('X-Axis Estimates');
plot(ax, squeeze(loc_est_history(:,:,1))', 'x')
plot(ax, traj(:,:,1)', '--');

loc_est_sorted = assign_estimates_tracking(sources,loc_est_history);
ax = subplot_tight(1,sources.n,2); hold on;
title('Y-Axis Estimates');
plot(ax, squeeze(loc_est_sorted(:,:,2))', 'x')
plot(ax, traj(:,:,2)', '--');
