%% Setup Environment
fprintf('------------------------- T E S T R U N -------------------------\n');
tic;
config_update(4, true, 10);
load('config.mat');

%% Simulate Environment
x = simulate(ROOM, R, sources);

%% Calculate STFT
[X, phi] = stft(x);

%% Estimate Location (GMM+EM-Algorithmus)
[psi, iterations] = em_algorithm(phi, 10, 0.01, true);
loc_est = estimate_location(squeeze(psi(size(psi, 1), :, :)), n_sources, 0, 5, room);
[loc_est_sorted, est_err] = estimation_error(S, loc_est);

%% Plotting results
psi_plot = zeros(em.Y,em.X);
psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
[ fig ] = plot_results( psi_plot, loc_est, room);

%% End
fprintf('\n---------------------   E N D   ---------------------\n');