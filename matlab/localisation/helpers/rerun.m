%% Setup Environment
cprintf('comment', '--------------------- R E R U N   T E S T ---------------------\n');
% You need to copy the config.mat file, that you want to rerun, to /localisation
load('config.mat');
tic;

%% Simulate Environment
x = simulate(ROOM, R, sources);

%% Calculate STFT
[X, phi] = stft(x);

%% Estimate Location (GMM+EM-Algorithmus)
psi = em_algorithm(phi, 5, 0.001);
loc_est = estimate_location(psi, n_sources, elimination_radius, min_distance, room);
[loc_est_sorted, est_err] = estimation_error_rad(S, loc_est);

%% Print Results
for s=1:n_sources
    fprintf("%s Source #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f], Error = %0.2f\n", FORMAT_PREFIX, s, S(s,1:2), loc_est_sorted(s, :), est_err(s));
end
fprintf("%s Average Estimation Error = %0.2f (t = %2.4f)\n", FORMAT_PREFIX, mean(est_err), toc);

%% Plot results
psi_plot = zeros(em.Y,em.X);
psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
[ fig ] = plot_results( psi_plot, loc_est, room);

%% End
cprintf('comment', '\n---------------------   E N D   ---------------------\n');