%% setting parameters
src_cfg = 'arc';
T60=0.4;
SNR=30;
% reflect_order=5;
samples=500;
source_length = 5; % seconds
freq_range=[];
sim_method = 'fastISM';
clean = true;

% change into working directory, so temporary files are in one (and only one) place
oldpath = pwd;
PATH_SRC = [getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'temp'];
[~,~] = mkdir(PATH_SRC); cd(PATH_SRC);

%% init
tic;
config_update_tracking(src_cfg,T60,reflect_order,SNR,samples,source_length,freq_range,sim_method);
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% SIMULATE
[x, sources.sdata] = simulate_tracking(false);
save('sources.mat', 'x');
[X, phi] = stft('config.mat', x);

%% SOURCE TRACKING
ang_dist = rem_init(phi);
[psi_crem, loc_est_crem, var_hist(1,1,:), psi_history_crem] = rem_tracking(ang_dist, 'crem', 1);
[psi_trem, loc_est_trem, var_hist(2,1,:), psi_history_trem] = rem_tracking(ang_dist, 'trem', 1);
% [loc_est_sorted, est_err] = assign_estimates_tracking(sources, loc_est);
% analyse_em_steps_tracking(psi_crem, squeeze(var_hist(1,:,:)), room, sources);

% plot variance
plot_variance(var_hist, {'CREM','TREM'}, c);

plot_loc_est_history_c(loc_est_crem, sources)
plot_loc_est_history_c(loc_est_trem, sources)

%% PLOTTING
plot_results_tracking(loc_est_crem, sources, room, 'CREM')
plot_results_tracking(loc_est_trem, sources, room, 'TREM')
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
cd(oldpath)
if clean, rmdir(PATH_SRC); end
cprintf('err', '\n---------------------   E N D   ---------------------\n');
