%% setting parameters
src_config = 'parallel';
T60=0.4;
SNR=30;
% reflect_order=;
samples=500;
source_length = 5; % seconds
freq_range=[];
sidx = false;
method='fastISM';

%% init
% change into working directory, so temporary files are in one (and only one) place
cd([getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'mainczjs_tracking' filesep 'evaluation' filesep 'results']) 
tic;
config_update_tracking(src_config,T60,reflect_order,SNR,samples,source_length,freq_range,method);
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% SIMULATE
[x, sources.sdata] = simulate_tracking();
[X, phi] = stft('config.mat', x);
ang_dist = rem_init(phi);

%% SOURCE TRACKING
init_vars = [.1, .5, 1, 2, 5];
var_hist = zeros(2,length(init_vars),em.T+1);
for v=1:length(init_vars)
    [psi_crem, loc_est_crem, var_hist(1,v,:), psi_history_crem] = rem_tracking(ang_dist, 'crem', init_vars(v));
    [psi_trem, loc_est_trem, var_hist(2,v,:), psi_history_trem] = rem_tracking(ang_dist, 'trem', init_vars(v));
end

% analyse_em_steps_tracking(psi_history, var_history, room, sources);

%% PLOTTING
plot_variance(var_hist, {'CREM','TREM'}, c);

scr_size = get(0,'ScreenSize');  % [1, 1, 2560, 1440] on 2k resolution screen
offset = 100;
fig_size = [(scr_size(3)-2*offset)/4 scr_size(4)-2*offset];  % width x height
fig_xpos = ceil(scr_size(3)/4);
fig_ypos = ceil((scr_size(4)-2*offset-fig_size(2))/2); % center the figure on the screen vertically
% 'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)]);

fig_crem = figure('Name', 'Estimated Coordinates over Time (CREM)', 'Position', [offset,offset,fig_size(1),fig_size(2)]);
plot_loc_est_history_c(loc_est_crem, sources, fig_crem)
fig_trem = figure('Name', 'Estimated Coordinates over Time (TREM)', 'Position', [fig_xpos+offset,offset,fig_size(1), fig_size(2)]);
plot_loc_est_history_c(loc_est_trem, sources, fig_trem)

fig_results_crem = figure('Name', 'Tracking Results (CREM)', 'Position', [2*fig_xpos+offset,offset,fig_size(1),fig_size(2)/2-50]);
plot_results_tracking(loc_est_crem, sources, room, 'CREM', fig_results_crem)
fig_results_trem = figure('Name', 'Tracking Results (TREM)', 'Position', [2*fig_xpos+offset,offset+fig_size(2)/2+50,fig_size(1),fig_size(2)/2-50]);
plot_results_tracking(loc_est_trem, sources, room, 'TREM', fig_results_trem)
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
cprintf('err', '\n---------------------   E N D   ---------------------\n');
