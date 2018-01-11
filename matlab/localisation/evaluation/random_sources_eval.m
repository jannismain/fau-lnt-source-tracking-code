function [results] = random_sources_eval(description, n_sources, trials, min_distance, distance_wall, randomise_samples, T60, snr, em_iterations, em_conv_threshold, guess_randomly, reflect_order, var_init, var_fixed, results_dir, alt_err)
%% RANDOM_SOURCES_EVAL Evaluates the localisation algorithm using random source locations
% This is the main routine used for running evaluation trials of the static localisation
% algorithm.
%% TODO
% * Find out what happens, when sources are known a-priori but wrong (3
% instead of 2 for example)
%
%% NOTES
% * |<matlab:doc('evalc') evalc()>| is used to supress output from these functions.
%
%% MLINT ANNOTATIONS
% The annotations allow suppress some warnings
%#ok<*ASGLU>  % this suppresses 'value not used' due to evalc() calls
%#ok<*NASGU>  % this suppresses 'this value is used before assigned' due to evalc() calls
%#ok<*INUSL>  % this suppresses 'input argument might be unused' due to evalc() calls
%#ok<*INUSD>

%% Arguments
% * *description (str)*: _name of evaluation trial (used as name of results subfolder, default: *'no-name-specified'*)_
% * *n_sources (int)*: _number of sources (comment, default: *2*)_
% * *trials (int)*: _number of trials with identical parameter set (comment, default: *10*)_
% * *min_distance (int)*: _minimum required distance between sources (comment, default: *5*)_
% * *distance_wall (int)*: _minimum required distance between sources and wall (comment, default: *12*)_
% * *randomise_samples (bool)*: _description (comment, default: *false*)_
% * *T60 (double)*: _reverberation time $$ T_{60} $$ (in seconds, default: *0.3*)_
% * *snr (int)*: _amount of noise added to received signal (in dB, 0 equals no noise, default: *0*)_
% * *em_iterations (int)*: _number of maximum em iterations (default: *5*)_
% * *em_conv_threshold (int)*: _convergence threshold for em algorithm (-1 equals no threshold, default: *-1*)_
% * *guess_randomly (bool)*: _guess location estimates instead of using em algorithm (default: *false*)_
% * *reflect_order (int)*: _maximum reflection order for image-method simulation (-1 equals max, default: *3*)_
% * *var_init (double)*: _initial value for variance (default: *0.1*)_
% * *var_fixed (bool)*: _do not estimate variance for each em iteration (default: *false*)_
% * *results_dir ([str|bool])*: _path to custom results folder (used on remote servers to collect results into specific folder, default: *false*)_
% * *alt_err (bool)*: _use alternative error calculation (default: *true*)_

if nargin < 1,  description = 'no-name-specified'; end
if nargin < 2,  n_sources = 2; end
if nargin < 3,  trials = 10; end
if nargin < 4,  min_distance = 5; end
if nargin < 5,  distance_wall = 12; end
if nargin < 6,  randomise_samples = true; end
if nargin < 7,  T60 = 0.3; end
if nargin < 8,  snr = 0; end
if nargin < 9,  em_iterations = 10; end
if nargin < 10, em_conv_threshold = -1; end
if nargin < 11, guess_randomly = false; end
if nargin < 12, reflect_order = 3; end
if nargin < 13, var_init = 0.1; fprintf('WARNING: Using default initial variance (0.1)\n'); end
if nargin < 14, var_fixed = false; fprintf('WARNING: Using default for var_fixed (false)\n'); end
if nargin < 15, results_dir = false; end
if nargin < 16, alt_err = true; end

%% Initialisation
cprintf('-comment', '                            E V A L U A T I O N                            \n');

% change path to results dir
if ~results_dir
    PATH_SRC = [getuserdir filesep 'thesis' filesep];
else
    PATH_SRC = results_dir;
end
PATH_MATLAB_RESULTS_ROOT = strcat(PATH_SRC, 'src', filesep, 'matlab', filesep, 'localisation', filesep, 'evaluation', filesep, 'results', filesep);
PATH_MATLAB_RESULTS = strcat(PATH_MATLAB_RESULTS_ROOT, description);
PATH_LATEX_ABS = [PATH_SRC 'latex' filesep 'data' filesep 'plots' filesep 'static' filesep 'tikz-data' filesep];
PATH_LATEX_RESULTS = [PATH_SRC 'latex' filesep 'data' filesep];

oldpath = pwd;
% [~, ~] = mkdir(PATH_MATLAB_RESULTS_ROOT, description);  % at least 2 argout's are required to suppress warning if dir already exists
[~, ~] = mkdir(PATH_MATLAB_RESULTS);
cd(PATH_MATLAB_RESULTS);
[~, ~] = mkdir('raw');

% init filename
time_start = datestr(now(), 'yyyy-mm-dd-HH-MM-SS.FFF');
fname_base = sprintf('%s_s=%d_md=%0.1f_wd=%0.1f_T60=%0.1f_SNR=%d_em=%d_refl-ord=%d_var-fixed=%d_var-val=%0.1f_', time_start, n_sources, min_distance/10, distance_wall/10, T60, snr, em_iterations, reflect_order, var_fixed, var_init);
% init empty matrices
est_err = zeros(trials, n_sources);
loc_est = zeros(trials, n_sources, 2);
loc_est_assorted = zeros(trials, n_sources, 2);
loc = zeros(trials, n_sources, 2);
results = zeros(trials, n_sources*5);  % realX, realY, estX, estY, estErr
log = '';
tic;

%% Trial
for trial=1:trials
    fprintf('[Trial %2d/%2d] s=%d, md=%0.1f, wd=%0.1f, T60=%0.1f, em=%d, ord=%d:', trial, trials, n_sources, min_distance/10, distance_wall/10, T60, em_iterations, reflect_order);
    [log_conf, fn_conf] = evalc('config_update(n_sources, true, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold, reflect_order, snr, var_init, var_fixed);');
    load(fn_conf);
    if guess_randomly
        [log_sim, random_estimate] = evalc('get_random_sources(n_sources, distance_wall, min_distance, room.dimensions);');
        loc_est_assorted(trial, :, :) = random_estimate(:, 1:2);
    else
        [log_sim, x] = evalc('simulate(fn_conf, ROOM, R, sources);');
        [log_stft, X, phi] = evalc('stft(fn_conf, x);');
        [log_em, psi, real_iterations] = evalc('em_algorithm(fn_conf, phi);');
        [log_estloc, loc_est_assorted(trial, :, :)] = evalc('estimate_location(psi, n_sources, 2, min_distance, room);');
    end
    if alt_err
        [log_esterr, loc_est(trial, :, :), est_err(trial, :)] = evalc('estimation_error_rad(S, squeeze(loc_est_assorted(trial, :, :)));');
    else
        [log_esterr, loc_est(trial, :, :), est_err(trial, :)] = evalc('estimation_error(S, squeeze(loc_est_assorted(trial, :, :)));');
    end
    fprintf(' err_m = %0.2f (t = %4.2f)\n', mean(est_err(trial, :)), toc');
    if mean(est_err(trial, :))>mean(mean(est_err)*2)
        for s=1:n_sources
            fprintf('%s Source Location #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f]\n', FORMAT_PREFIX, s, S(s,1:2), loc_est(trial, s, :));
        end
    end

    %% Save Results of Single Trial
    loc_est_reshaped = reshape(squeeze(loc_est(trial,:,:))',1,size(loc_est, 2)*size(loc_est, 3));
    S_reshaped = reshape(S(:, 1:2)', 1, size(S, 1)*2);
    results(trial, :) = [S_reshaped loc_est_reshaped est_err(trial, :)];

    if ~guess_randomly  % save raw data (fig, config_xxx.mat)
        fname_trial = sprintf('%strial_%d_of_%d_', fname_base, trial, trials);
        psi_plot = zeros(em.Y,em.X);
        psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
        if LOGGING_FIG
            fig = plot_results( psi_plot, squeeze(loc_est(trial, :, :)), room);
            saveas(fig, strcat('raw', filesep, fname_trial, '.fig'), 'fig');
            close(fig);
        end
        % matlab2tikz(strcat(PATH_SRC, '/latex/data/plots/static/', fname_trial, 'fig.tex'), 'figurehandle', fig, 'imagesAsPng', true, 'checkForUpdates', false, 'externalData', false, 'relativeDataPath', 'data/plots/static/tikz-data/', 'dataPath', PATH_LATEX_ABS, 'noSize', false, 'showInfo', false);
        movefile(fn_conf, strcat('raw', filesep, fname_trial, 'config.mat'));
        if LOGGING
            logfile = fopen(strcat('raw', filesep, fname_trial, 'log.txt'), 'w');
            fprintf(logfile, log_conf);
            fprintf(logfile, log_sim);
            fprintf(logfile, log_stft);
            fprintf(logfile, log_em);
            fprintf(logfile, log_estloc);
            fprintf(logfile, log_esterr);
            fclose(logfile);
        end
    else
        delete(fn_conf);
    end
end

%% Save Results of All Trials
fprintf('[  RESULTS  ]: err_mean = %0.2f, max = %0.2f, min = %0.2f (t/trial = %0.2fs, t = %dm %ds)\n', mean(mean(est_err)), max(max(est_err)), min(min(est_err)), toc/trials, floor(toc/60), round(toc-floor(toc/60)*60, 0));
save(strcat(fname_base, 'results.mat'), 'results'); % for further processing in matlab
save(strcat(fname_base, 'results.txt'), 'results', '-ascii', '-double', '-tabs'); % for further processing in python

% for display of raw data table in LaTeX
clabels = get_column_names_result(n_sources);
matrix2latex(results, strcat(PATH_LATEX_RESULTS, 'tables', filesep, fname_base, 'results.tex'), 'columnLabels', clabels);

%% End
cd(oldpath);
end
