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
[psi, est_error1, est_error2] = bren_estimate_location(cfg, phi);

%% End
cprintf('comment', '\n---------------------   E N D   ---------------------\n');