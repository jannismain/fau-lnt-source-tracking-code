function [results] = random_sources_eval(description, n_sources, trials, min_distance, distance_wall, randomize_samples, T60, snr, em_iterations, em_conv_threshold, guess_randomly, reflect_order, var_init, var_fixed, results_dir, prior, sources)
% Evaluates the localisation algorithm using random source locations
% TODO: Also use different flavors of estimation algorithm (variance fixed
% or calculated, sources known a priori vs. sources unknown)
%
% NOTES:
%   - evalc() is used to supress output from these functions.
%
%#ok<*ASGLU>  % this suppresses 'value not used' due to evalc() calls
%#ok<*NASGU>  % this suppresses 'this value is used before assigned' due to evalc() calls
%#ok<*INUSL>  % this suppresses 'input argument might be unused' due to evalc() calls
%#ok<*INUSD>

%% setting default arg values
if nargin < 1,  description = 'no-name-specified'; end
if nargin < 2,  n_sources = 2; end
if nargin < 3,  trials = 10; end
if nargin < 4,  min_distance = 5; end
if nargin < 5,  distance_wall = 12; end
if nargin < 6,  randomize_samples = false; end
if nargin < 7,  T60 = 0.3; end
if nargin < 8,  snr = 0; end
if nargin < 9,  em_iterations = 5; end
if nargin < 10, em_conv_threshold = -1; end
if nargin < 11, guess_randomly = false; end
if nargin < 12, reflect_order = 3; end
if nargin < 13, var_init = 0.1; end
if nargin < 14, var_fixed = false; end
if nargin < 15, results_dir = false; end
if nargin < 16, prior = 'equal'; end
if nargin < 17, sources='leftright'; end


%% initialisation
cprintf('-comment', '                            E V A L U A T I O N                            \n');

% change path to results dir
if ~results_dir
    PATH_SRC = [getuserdir filesep 'thesis' filesep 'src' filesep];
else
    PATH_SRC = results_dir;
end
PATH_MATLAB_RESULTS_ROOT = strcat(PATH_SRC, 'matlab', filesep, 'mainczjs', filesep, 'evaluation', filesep, 'psi_s', filesep);
PATH_MATLAB_RESULTS = PATH_MATLAB_RESULTS_ROOT;
PATH_LATEX_RESULTS = [getuserdir filesep 'thesis' filesep 'latex' filesep 'data' filesep 'plots' filesep 'psi_s' filesep];

oldpath = pwd;
[~, ~] = mkdir(PATH_MATLAB_RESULTS);
cd(PATH_MATLAB_RESULTS);
[~, ~] = mkdir('raw');

% init filename
time_start = datestr(now(), 'yyyy-mm-dd-HH-MM-SS.FFF');
fname_base = sprintf('%s_s=%d_md=%0.1f_wd=%0.1f_T60=%0.1f_SNR=%d_em=%d_refl-ord=%d_var-fixed=%d_var-val=%0.1f_prior=%s_', time_start, n_sources, min_distance/10, distance_wall/10, T60, snr, em_iterations, reflect_order, var_fixed, var_init,prior);

% init empty matrices
est_err = zeros(trials, n_sources);
loc_est = zeros(trials, n_sources, 2);
loc_est_assorted = zeros(trials, n_sources, 2);
loc = zeros(trials, n_sources, 2);
results = zeros(trials, n_sources*5);  % realX, realY, estX, estY, estErr
log = '';
tic;

%% trials
for trial=1:trials
    fprintf('[Trial %3d/%3d] s=%d, source-cfg=%s, T60=%0.1f, prior=%s:', trial, trials, n_sources, sources, T60, prior);
    [log_conf, fn_conf] = evalc('config_update(n_sources, sources, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold, reflect_order, snr, var_init, var_fixed, prior);');
    load(fn_conf);
    [log_sim, x] = evalc('simulate(fn_conf, ROOM, R, sources);');
    [log_stft, X, phi] = evalc('stft(fn_conf, x);');
    [log_em , psi, iterations, variance] = evalc('em_algorithm(fn_conf, phi, em.iterations, em_conv_threshold, true, false, prior);');
    
    psi_mixed = squeeze(sum(psi(end,:,:,:),2));
    [log_estloc, loc_est_assorted(trial, :, :)] = evalc('estimate_location(psi_mixed, n_sources, 0, min_distance, room);');
    [log_esterr, loc_est(trial, :, :), est_err(trial, :)] = evalc('estimation_error(S, squeeze(loc_est_assorted(trial, :, :)));');
    fprintf(' err_m = %0.2f (t = %4.2f)\n', mean(est_err(trial, :)), toc');

    %% archive results
    loc_est_reshaped = reshape(squeeze(loc_est(trial,:,:))',1,size(loc_est, 2)*size(loc_est, 3));
    S_reshaped = reshape(S(:, 1:2)', 1, size(S, 1)*2);
    results(trial, :) = [S_reshaped loc_est_reshaped est_err(trial, :)];

    fname_trial = sprintf('%st%d_of_t%d_', fname_base, trial, trials);
    
    psi_plot = zeros(em.Y,em.X);
    psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi_mixed;
    if LOGGING_FIG
        fig1 = plot_overview(psi,variance,iterations,em,room, 'all', strcat(PATH_LATEX_RESULTS , 'single', filesep, 'overview'), strcat(PATH_MATLAB_RESULTS, fname_trial, 'config.mat'));
        fig2 = plot_results( psi_plot, squeeze(loc_est(trial, :, :)), room, 'all', strcat(PATH_LATEX_RESULTS , fname_trial, 'results'));
        close all;
    end
    
    movefile(fn_conf, strcat(PATH_MATLAB_RESULTS, fname_trial, 'config.mat'));
    if LOGGING
        logfile = fopen(strcat(PATH_MATLAB_RESULTS, fname_trial, 'log.txt'), 'w');
        fprintf(logfile, log_conf);
        fprintf(logfile, log_sim);
        fprintf(logfile, log_stft);
        fprintf(logfile, log_em);
        fprintf(logfile, log_estloc);
        fprintf(logfile, log_esterr);
        fclose(logfile);
    end
end

%% save results
fprintf('[  RESULTS  ]: err_mean = %0.2f, max = %0.2f, min = %0.2f (t/trial = %0.2fs, t = %dm %ds)\n', mean(mean(est_err)), max(max(est_err)), min(min(est_err)), toc/trials, floor(toc/60), round(toc-floor(toc/60)*60, 0));
% save(strcat(fname_base, 'results.mat'), 'results');
save(strcat(fname_base, 'results.txt'), 'results', '-ascii', '-double', '-tabs');
% clabels = get_column_names_result(n_sources);
% matrix2latex(results, strcat(PATH_LATEX_RESULTS, 'tables', filesep, fname_base, 'results.tex'), 'columnLabels', clabels);

%% end
cd(oldpath);
end
