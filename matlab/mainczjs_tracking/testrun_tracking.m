%% setting parameters
n_sources = 2;
T60=0.0;
SNR=0;
reflect_order=1;
samples=100;
source_length = 5; % seconds
freq_range=[];
sidx=false;  % run algorithm only for single source
sim_method = 'fastISM';

%% init
tic;
config_update_tracking(n_sources,T60,reflect_order,SNR,samples,source_length,freq_range,sidx,sim_method);
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% SIMULATE
x = simulate_tracking();
save('sources.mat', 'x');
[X, phi] = stft('config.mat', x);

%% SOURCE TRACKING
ang_dist = rem_init(phi);
[psi, loc_est, var_history, psi_history] = rem_tracking(ang_dist, 'crem', 1);
[loc_est_sorted, est_err] = assign_estimates_tracking(sources, loc_est);
% analyse_em_steps_tracking(psi_history, var_history, room, sources);

plot_loc_est_history_c(loc_est_crem)
% plot variance
figure('Name','Variance across Iterations');
plot(var_history);

%% PLOTTING
plot_results_tracking(loc_est, sources, room)
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');

cprintf('err', '\n---------------------   E N D   ---------------------\n');
