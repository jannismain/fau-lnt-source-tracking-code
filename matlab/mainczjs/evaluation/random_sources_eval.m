function [results] = random_sources_eval(description, n_sources, trials, min_distance, distance_wall, randomize_samples, T60, snr, em_iterations, em_conv_threshold, guess_randomly)  
% Evaluates the localisation algorithm using random source locations
% TODO: Also use different flavors of estimation algorithm (variance fixed
% or calculated, sources known a priori vs. sources unknown)
%
% TODO: Find out what happens, when sources are known a-priori but wrong (3
% instead of 2 for example)
% NOTES:
%   - evalc() is used to supress output from these functions.
%
%#ok<*ASGLU>  % this suppresses "value not used" due to evalc() calls
%#ok<*NASGU>  % this suppresses "this value is used before assigned" due to evalc() calls
%#ok<*INUSL>  % this suppresses "input argument might be unused" due to evalc() calls
%#ok<*INUSD>

%% setting default arg values
if nargin < 1, description = 'no-name-specified'; end
if nargin < 2, n_sources = 2; end
if nargin < 3, trials = 10; end
if nargin < 4, min_distance = 5; end
if nargin < 5, distance_wall = 15; end
if nargin < 6, randomize_samples = False; end
if nargin < 7, T60 = 0; end 
if nargin < 8, snr = 0; end
if nargin < 9, em_iterations = 10; end
if nargin < 10, em_conv_threshold = -1; end
if nargin < 10, guess_randomly = false; end


%% initialisation
cprintf('-comment', '                            E V A L U A T I O N                            \n');

% change path to results dir
PATH_SRC = [getuserdir filesep 'Dropbox' filesep '01. STUDIUM' filesep '10. Masterarbeit' filesep 'src' filesep];
PATH_MATLAB_RESULTS_ROOT = strcat(PATH_SRC, 'matlab', filesep, 'mainczjs', filesep, 'evaluation', filesep, 'results', filesep);
PATH_MATLAB_RESULTS = strcat(PATH_MATLAB_RESULTS_ROOT, description);
PATH_LATEX_ABS = [PATH_SRC 'latex' filesep 'data' filesep 'plots' filesep 'static' filesep 'tikz-data' filesep];
PATH_LATEX_RESULTS = [PATH_SRC 'latex' filesep 'data' filesep];
oldpath = pwd;
[~, ~] = mkdir(PATH_MATLAB_RESULTS_ROOT, description);  % at least 2 argout's are required to suppress warning if dir already exists
cd(PATH_MATLAB_RESULTS);
[~, ~] = mkdir('raw');

% init filename
time_start = datestr(now(), 'yyyy-mm-dd-HH-MM-SS');
fname_base = sprintf('%s_s=%d_md=%0.1f_wd=%0.1f_T60=%0.1f_SNR=%d_em=%d_', time_start, n_sources, min_distance/10, distance_wall/10, T60, snr, em_iterations);
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
    fprintf('[Trial %2d/%2d] %ds, %0.1fmd, %0.1fwd, %0.1fT60, %2dem:', trial, trials, n_sources, min_distance/10, distance_wall/10, T60, em_iterations);
    evalc('config_update(n_sources, true, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold);');
    load('config.mat');
    if guess_randomly
        [log_sim, random_estimate] = evalc('get_random_sources(n_sources, distance_wall, min_distance, room.dimensions);');
        loc_est_assorted(trial, :, :) = random_estimate(:, 1:2);
    else
        [log_sim, x] = evalc('simulate(ROOM, R, sources);');
        [log_stft, X, phi] = evalc('stft(x);');
        [log_em, psi, real_iterations] = evalc('em_algorithm(phi);');
        [log_estloc, loc_est_assorted(trial, :, :)] = evalc('estimate_location(psi, n_sources, 2, min_distance, room);');
    end
    [log_esterr, loc_est(trial, :, :), est_err(trial, :)] = evalc('estimation_error(S, squeeze(loc_est_assorted(trial, :, :)));');
    fprintf(" mean_err = %0.2f (t = %3.2f)\n", mean(est_err(trial, :)), toc');
    if mean(est_err(trial, :))>mean(mean(est_err)*2)
        for s=1:n_sources
            fprintf("%s Source Location #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f]\n", FORMAT_PREFIX, s, S(s,1:2), loc_est(trial, s, :));
        end
    end
    
    %% archive results
    loc_est_reshaped = reshape(squeeze(loc_est(trial,:,:))',1,size(loc_est, 2)*size(loc_est, 3));
    S_reshaped = reshape(S(:, 1:2)', 1, size(S, 1)*2);
    results(trial, :) = [S_reshaped loc_est_reshaped est_err(trial, :)];
    
    if ~guess_randomly  % save raw data (fig, config.mat)
        fname_trial = sprintf('%strial_%d_of_%d_', fname_base, trial, trials);
        psi_plot = zeros(em.Y,em.X);
        psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
        fig = plot_results( psi_plot, squeeze(loc_est(trial, :, :)), room);
        saveas(fig, strcat('raw', filesep, fname_trial, 'fig.fig'), 'fig');
        % matlab2tikz(strcat(PATH_SRC, '/latex/data/plots/static/', fname_trial, 'fig.tex'), 'figurehandle', fig, 'imagesAsPng', true, 'checkForUpdates', false, 'externalData', false, 'relativeDataPath', 'data/plots/static/tikz-data/', 'dataPath', PATH_LATEX_ABS, 'noSize', false, 'showInfo', false);
        close(fig);
        movefile('config.mat', strcat('raw', filesep, fname_trial, 'config.mat'));
        %% save log
        logfile = fopen(strcat('raw', filesep, fname_trial, 'log.txt'), 'w');
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