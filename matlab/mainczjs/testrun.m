%% Setup Environment
clear all;
cprintf('comment', '--------------------- T E S T R U N ---------------------\n');
tic;
config_update(4, true, 10);
load('config.mat');

%% Simulate Environment
x = simulate(ROOM, R, S);

%% Calculate STFT
[X, phi] = stft(x);

%% Estimate Location (GMM+EM-Algorithmus)
psi = em_algorithm(phi, 5);
loc_est = estimate_location(psi, n_sources);
[loc_est_sorted, est_err] = estimation_error(S, loc_est);

%% Plotting results
psi_plot = zeros(em.Y,em.X);
psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
[ fig ] = plot_results( psi_plot, loc_est, room);

%% End
cprintf('comment', '\n---------------------   E N D   ---------------------\n');