function [fig] = plot_loc_est_history_s(loc_est_history, sources, fig)

if nargin<3, fig = figure('Name','Coordinates across Iterations','Position', [100 100 1400 1400]); end

T = size(loc_est_history, 2);
for s=1:sources.n
    traj = get_trajectory_from_source(squeeze(sources.p(s,:)),squeeze(sources.movement(s,:)), T);
    
    ax = subplot_tight(2,sources.n,s); hold on;
    title(sprintf('S_{%d} (raw)', s));
    plot(ax, squeeze(loc_est_history(s,:,:)))
    plot(ax, traj(:,1:2), '--');
    
    loc_est_sorted = assign_estimates_tracking(sources,loc_est_history);
    ax = subplot_tight(2,sources.n,s+sources.n); hold on;
    title(sprintf('S_{%d} (assigned)', s));
    plot(ax, squeeze(loc_est_sorted(s,:,:)))
    plot(ax, traj(:,1:2), '--');
end
