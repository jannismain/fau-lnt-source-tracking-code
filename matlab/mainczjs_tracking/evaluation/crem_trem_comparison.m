%% setting parameters
n_sources = 2;
T60=0.0;
SNR=0;
reflect_order=1;
samples=50;
source_length = 5; % seconds
freq_range=[];
sidx = false;
method='fastISM';

%% init
tic;
config_update_tracking(n_sources,T60,reflect_order,SNR,samples,source_length,freq_range,sidx,method);
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% SIMULATE
x = simulate_tracking();
[X, phi] = stft('config.mat', x);
ang_dist = rem_init(phi);

%% SOURCE TRACKING
init_vars = [.1, .5, 2];
var_hist = zeros(2,length(init_vars),em.T+1);
for v=1:length(init_vars)
    [psi_crem, loc_est_crem, var_hist(1,v,:), psi_history_crem] = rem_tracking(ang_dist, 'crem', init_vars(v));
    [psi_trem, loc_est_trem, var_hist(2,v,:), psi_history_trem] = rem_tracking(ang_dist, 'trem', init_vars(v));
end

% analyse_em_steps_tracking(psi_history, var_history, room, sources);

%% PLOTTING
plot_variance(var_hist, {'CREM','TREM'}, c);

plot_loc_est_history_c(loc_est_crem, sources)
plot_loc_est_history_c(loc_est_trem, sources)
plot_loc_est_history_s(loc_est_crem, sources)
plot_loc_est_history_s(loc_est_trem, sources)

plot_results_tracking(loc_est_crem, sources, room)
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
cprintf('err', '\n---------------------   E N D   ---------------------\n');
