function [] = config_shift_current_trajectory(i)
%CONFIG_SHIFT_CURRENT_TRAJECTORY Summary of this function goes here
%   Detailed explanation goes here
    
    load('config.mat');
    current_trajectory = squeeze(sources.trajectories(i, :, :));
    save('traj.mat', 'current_trajectory')

end

