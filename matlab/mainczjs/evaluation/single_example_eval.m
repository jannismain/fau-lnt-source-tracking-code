function [ est_err ] = single_example_eval(n_sources, rand_sources, md, wd, T60, max_em_iterations, em_conv_threshold)

%% Setup Environment
fprintf('--------------------- E V A L U A T I O N ---------------------\n');
config_update(n_sources, rand_sources, md, wd, true, T60, max_em_iterations, em_conv_threshold)
load('config.mat');
tic;

%% Testrun
x = simulate(ROOM, R, sources);
[~, phi] = stft(x);
[psi, iter] = em_algorithm(phi, max_em_iterations, em_conv_threshold, true);

%% Visualise Results
analyse_em_steps(psi, n_sources, md, room, S);

%% End
fprintf('\n---------------------   E N D   ---------------------\n');