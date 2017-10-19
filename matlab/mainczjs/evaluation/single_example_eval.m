function [ est_err ] = single_example_eval(n_sources, rand_sources, md, wd, T60, max_em_iterations, em_conv_threshold)

%% Setup Environment
fprintf('--------------------- E V A L U A T I O N ---------------------\n');
config_update(n_sources, rand_sources, md, wd, true, T60, max_em_iterations, em_conv_threshold)
load('config.mat');
tic;

%% Testrun
x = simulate(ROOM, R, sources);
[X, phi] = stft(x);
psi = em_algorithm(phi, max_em_iterations, em_conv_threshold, true);

%% Visualise Results
plot_em_steps(psi, n_sources, md, room, S);
% for s=1:n_sources
%     fprintf("%s Source #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f], Error = %0.2f\n", FORMAT_PREFIX, s, S(s,1:2), loc_est_sorted(s, :), est_err(s));
% end
% fprintf("%s Average Estimation Error = %0.2f (t = %2.4f)\n", FORMAT_PREFIX, mean(est_err), toc);

%% End
fprintf('\n---------------------   E N D   ---------------------\n');