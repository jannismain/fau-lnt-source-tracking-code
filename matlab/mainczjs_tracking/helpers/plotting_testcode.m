%% EXAMPLE CODE, CAN BE REMOVED LATER
if nargin < 1
    S = [2 2 3;
         2 3 3;
         1 5 3];
    M = [0 1 0;
         2 2 0;
         2 -2 0];
    n_sources = size(S, 1);
    n_dim = size(S, 2);
    n_samples = 100;
    traj = zeros(n_sources,n_samples,n_dim);
    for s=1:n_sources
        temp = get_trajectory_from_source(S(s, :), M(s,:), n_samples);
        traj(s, :, :) = get_trajectory_from_source(S(s, :), M(s,:), n_samples);
    end
end