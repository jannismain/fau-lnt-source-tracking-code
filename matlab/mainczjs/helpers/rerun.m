%% Setup Environment
cprintf('comment', '--------------------- R E R U N   T E S T ---------------------\n');
% You need to copy the config.mat file, that you want to rerun, to /mainczjs
load('config.mat');
tic;

%% Simulate Environment
x = simulate(ROOM, R, sources);

%% Calculate STFT
[X, phi] = stft(x);

%% Estimate Location (GMM+EM-Algorithmus)
psi = em_algorithm(phi, 5);
loc_est = estimate_location(psi, n_sources, elimination_radius, min_distance);
[loc_est_sorted, est_err] = estimation_error(S, loc_est);

%% Print Results
for s=1:n_sources
    fprintf("%s Source Location #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f]\n", FORMAT_PREFIX, s, S(s,1:2), loc_est_sorted(s, :));
end
fprintf("%s Average Estimation Error = %0.2f (Elapsed time = %0.2f)\n", FORMAT_PREFIX, mean(est_err), toc');
% loc_est_reshaped = reshape(loc_est',1,size(loc_est, 1)*size(loc_est, 2));
% S_reshaped = reshape(S(:, 1:2)', 1, size(S, 1)*2);
% results(trial, :) = [S_reshaped loc_est_reshaped est_err(trial, :)];

%% Plot results
psi_plot = zeros(em.Y,em.X);
psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
[ fig ] = plot_results( psi_plot, loc_est, room);

%% End
cprintf('comment', '\n---------------------   E N D   ---------------------\n');