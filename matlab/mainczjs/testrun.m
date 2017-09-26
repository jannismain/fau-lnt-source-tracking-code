%% Setup Environment
clear all;
cprintf('comment', '--------------------- T E S T R U N ---------------------\n');
tic;
config_update(2, true, 10);
load('config.mat');

%% Simulate Environment
x = simulate(ROOM, R, S);

%% Calculate STFT
[X, phi] = stft(x);
cfg = set_params_evaluate_Gauss();

%% Estimate Location (GMM+EM-Algorithmus)
psi = em_algorithm(cfg, phi, 5);
loc_est = estimate_location(psi);
[est_error1, est_error2] = bren_estimate_location(cfg, loc_est);

%% Plotting results
psi_plot = zeros(cfg.Y,cfg.X);
psi_plot((cfg.N_margin+1):(cfg.Y-cfg.N_margin),(cfg.N_margin+1):(cfg.X-cfg.N_margin)) = psi;
[ fig ] = plot_results( psi_plot, loc_est, cfg );

%% End
cprintf('comment', '\n---------------------   E N D   ---------------------\n');