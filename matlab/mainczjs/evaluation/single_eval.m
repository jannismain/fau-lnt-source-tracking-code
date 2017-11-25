function [results] = single_eval(description, n_sources, min_distance, distance_wall, randomize_samples, T60, snr, em_iterations, em_conv_threshold, reflect_order, var_init, var_fixed, results_dir, prior, src_cfg)
% Evaluates the localisation algorithm using certain source configurations
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
if nargin < 3,  min_distance = 5; end
if nargin < 4,  distance_wall = 12; end
if nargin < 5,  randomize_samples = false; end
if nargin < 6,  T60 = 0.3; end
if nargin < 7,  snr = 0; end
if nargin < 8,  em_iterations = 5; end
if nargin < 9, em_conv_threshold = -1; end
if nargin < 10, reflect_order = 3; end
if nargin < 11, var_init = 0.1; end
if nargin < 12, var_fixed = false; end
if nargin < 13, results_dir = false; end
if nargin < 14, prior = 'equal'; end
if nargin < 15, src_cfg='leftright'; end

cprintf('-comment', '                            E V A L U A T I O N                            \n');

%% manage paths / file structure
if ~results_dir, PATH_SRC = [getuserdir filesep 'thesis' filesep 'src' filesep];
else, PATH_SRC = results_dir; end
PATH_MATLAB_RESULTS = strcat(PATH_SRC, 'matlab', filesep, 'mainczjs', filesep, 'evaluation', filesep, description, filesep);
PATH_LATEX_RESULTS = [getuserdir filesep 'thesis' filesep 'latex' filesep 'data' filesep 'plots' filesep description filesep];
oldpath = pwd; [~, ~] = mkdir(PATH_MATLAB_RESULTS); [~, ~] = mkdir(PATH_LATEX_RESULTS); cd(PATH_MATLAB_RESULTS);  % change to matlab results dir

% init filename
fname = sprintf('s=%d-sloc=%s-T60=%1.1f-prior=%s-', n_sources, src_cfg, T60, prior);

% init empty matrices
% est_err = zeros(trials, n_sources);
% loc_est = zeros(trials, n_sources, 2);
% loc_est_assorted = zeros(trials, n_sources, 2);
% loc = zeros(trials, n_sources, 2);
% results = zeros(trials, n_sources*5);  % realX, realY, estX, estY, estErr
log = '';
tic;

%% Run Algorithm
[log_conf, fn_conf] = evalc('config_update(n_sources, src_cfg, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold, reflect_order, snr, var_init, var_fixed, prior);');
load(fn_conf);
fprintf('%s s=%d, src-cfg=%s, prior=%s:', FORMAT_PREFIX, n_sources, src_cfg, prior);
[log_sim, x] = evalc('simulate(fn_conf, ROOM, R, sources);');
[log_stft, X, phi] = evalc('stft(fn_conf, x);');
[log_em , psi, iterations, variance] = evalc('em_algorithm(fn_conf, phi, em.iterations, em_conv_threshold, false, prior);');

psi_mixed = squeeze(sum(psi(end,:,:,:),2));  % mix last psi_s to get S best location estimates across all psi
[log_estloc, loc_est_assorted] = evalc('estimate_location(psi_mixed, n_sources, 0, min_distance, room);');
[log_esterr, loc_est, est_err] = evalc('estimation_error(S, loc_est_assorted);');
fprintf(' err_m = %0.2f (t = %4.2f)\n', mean(est_err), toc');

%% archive results
% save location estimates...
% loc_est_reshaped = reshape(squeeze(loc_est(trial,:,:))',1,size(loc_est, 2)*size(loc_est, 3));
% S_reshaped = reshape(S(:, 1:2)', 1, size(S, 1)*2);
% results(trial, :) = [S_reshaped loc_est_reshaped est_err(trial, :)];
% ...to txt
% save(strcat(fname_base, 'results.txt'), 'results', '-ascii', '-double', '-tabs');
% ...to tex
% clabels = get_column_names_result(n_sources);
% matrix2latex(results, strcat(PATH_LATEX_RESULTS, 'tables', filesep, fname_base, 'results.tex'), 'columnLabels', clabels);
% ...to mat
% save(strcat(fname_base, 'results.mat'), 'results');

% save plots
psi_plot = zeros(em.Y,em.X);
psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi_mixed;
if LOGGING_FIG
    fig1 = plot_overview(psi,variance,iterations,em,room, 'all', strcat(PATH_LATEX_RESULTS , fname, 'overview'), strcat(PATH_MATLAB_RESULTS, fname, 'overview'));
    fig2 = plot_results( psi_plot, loc_est, room, 'all', strcat(PATH_LATEX_RESULTS , fname, 'results'));
    close all;
end

% save config
close all
close all hidden
clear fig; clear fig1; clear fig2;
save(fn_cfg);  % save all temp results to config
movefile(fn_conf, strcat(PATH_MATLAB_RESULTS, fname, 'config.mat'));
if LOGGING
    logfile = fopen(strcat(PATH_MATLAB_RESULTS, fname, 'log.txt'), 'w');
    fprintf(logfile, log_conf);
    fprintf(logfile, log_sim);
    fprintf(logfile, log_stft);
    fprintf(logfile, log_em);
    fprintf(logfile, log_estloc);
    fprintf(logfile, log_esterr);
    fclose(logfile);
end

fprintf('[  RESULTS  ]: err_mean = %0.2f (t = %dm %ds)\n', mean(est_err), floor(toc/60), round(toc-floor(toc/60)*60, 0));

%% end
cd(oldpath);
end
