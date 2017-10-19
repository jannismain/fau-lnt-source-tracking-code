function [results] = random_estimates_eval(n_sources, trials, min_distance, distance_wall)  
% Approximates upper bound for mean_err, when location estimates are choosen at random
%
% NOTES:
%   - evalc() is used to supress output from these functions.
%
%#ok<*ASGLU>  % this suppresses "value not used" due to evalc() calls
%#ok<*NASGU>  % this suppresses "this value is used before assigned" due to evalc() calls
%#ok<*INUSL>  % this suppresses "input argument might be unused" due to evalc() calls
%#ok<*INUSD>

%% setting default arg values
if nargin < 1, n_sources = 2; end
if nargin < 2, trials = 10; end
if nargin < 3, min_distance = 5; end
if nargin < 4, distance_wall = 15; end

%% initialisation
fprintf('___________________________ E V A L U A T I O N ___________________________\n');

% change path to results dir
PATH_SRC = '/Users/jannismainczyk/Dropbox/01. STUDIUM/10. Masterarbeit/src/';
cd(PATH_SRC);
PATH_MATLAB_RESULTS_ROOT = 'matlab/mainczjs/evaluation/results/';
PATH_MATLAB_RESULTS_FOLDER_NAME = sprintf('%dsources-rnd-estimates', n_sources);
PATH_MATLAB_RESULTS = strcat(PATH_MATLAB_RESULTS_ROOT, PATH_MATLAB_RESULTS_FOLDER_NAME);
PATH_LATEX_ABS = strcat(PATH_SRC, 'latex/data/plots/static/tikz-data/');
PATH_LATEX_RESULTS = strcat(PATH_SRC, 'latex/data/');
oldpath = pwd;
[~, ~] = mkdir(PATH_MATLAB_RESULTS_ROOT, PATH_MATLAB_RESULTS_FOLDER_NAME);  % at least 2 argout's are required to suppress warning if dir already exists
cd(PATH_MATLAB_RESULTS);

% init filename
time_start = datestr(now(), 'yyyy-mm-dd-HH-MM-SS');
fname_base = sprintf('%s_%ds_%0.1fm_rnd_estimates_', time_start, n_sources, min_distance/10);
% init empty matrices
est_err = zeros(trials, n_sources);
loc_est = zeros(trials, n_sources, 2);
random_estimate = zeros(n_sources, 3);
loc_est_assorted = zeros(trials, n_sources, 2);
loc = zeros(trials, n_sources, 2);
results = zeros(trials, n_sources*5);  % realX, realY, estX, estY, estErr
tic;

%% trials
for trial=1:trials
    fprintf('[Trial %2d/%2d] %ds, %0.1fmd, %0.1fwd:', trial, trials, n_sources, min_distance/10, distance_wall/10);
    evalc('config_update(n_sources, true, min_distance, distance_wall);');
    load('config.mat');
    [~, random_estimate] = evalc('get_random_sources(n_sources, distance_wall, min_distance, room.dimensions);');
    loc_est_assorted(trial, :, :) = random_estimate(:, 1:2);
    [log_esterr, loc_est(trial, :, :), est_err(trial, :)] = evalc('estimation_error(S, squeeze(loc_est_assorted(trial, :, :)));');
    
    fprintf(" mean_err = %0.2f (t = %3.2f)\n", mean(est_err(trial, :)), toc);
    
    %% archive results
    loc_est_reshaped = reshape(squeeze(loc_est(trial,:,:))',1,size(loc_est, 2)*size(loc_est, 3));
    S_reshaped = reshape(S(:, 1:2)', 1, size(S, 1)*2);
    results(trial, :) = [S_reshaped loc_est_reshaped est_err(trial, :)];
    fname_trial = sprintf('%strial_%d_of_%d_', fname_base, trial, trials);
%     movefile('config.mat', strcat(fname_trial, 'config.mat'));
end

%% save results
fprintf('[  RESULTS  ]: err_mean = %0.2f, max = %0.2f, min = %0.2f (t_trial = %0.2fs, t = %dm %ds)\n', mean(mean(est_err)), max(max(est_err)), min(min(est_err)), toc'/trials, floor(toc'/60), round(toc'-floor(toc'/60), 0));
save(strcat(fname_base, 'results.txt'), 'results', '-ascii', '-double', '-tabs');
% clabels = get_column_names_result(n_sources);
% matrix2latex(results, strcat(PATH_LATEX_RESULTS, 'tables/', fname_base, 'results.tex'), 'columnLabels', clabels);

%% end
cd(oldpath);
end