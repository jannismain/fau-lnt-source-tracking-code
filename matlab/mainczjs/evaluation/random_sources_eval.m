function [results] = random_sources_eval(n_sources, trials, min_distance, T60, snr)
% Evaluates the localisation algorithm using random source locations
% TODO: after bren_location_estimate has been dealt with, truly parameterise for n sources (right now only 2 are supported)
% TODO: Also use different flavors of estimation algorithm (variance fixed
% or calculated, sources known a priori vs. sources unknown)
%
% TODO: Find out what happens, when sources are known a-priori but wrong (3
% instead of 2 for example)
% NOTES:
%   - evalc() is used to supress output from these functions.
%

%% setting default arg values
if nargin < 1, n_sources = 2; end
if nargin < 2, trials = 10; end
if nargin < 3, min_distance = 0.5; end
if nargin < 4, T60 = 0; end
if nargin < 5, snr = 0; end

%% initialisation
cprintf('-comment', '                E V A L U A T I O N                \n');

% change path to results dir
PATH_SRC = '/Users/jannismainczyk/Dropbox/01. STUDIUM/10. Masterarbeit/src/';
cd(PATH_SRC);
PATH_MATLAB_RESULTS_ROOT = 'matlab/mainczjs/evaluation/results/';
PATH_MATLAB_RESULTS_FOLDER_NAME = sprintf('%d_Sources_%d_MinDistance_%d_SNR', n_sources, min_distance, snr);
PATH_MATLAB_RESULTS = strcat(PATH_MATLAB_RESULTS_ROOT, PATH_MATLAB_RESULTS_FOLDER_NAME);
PATH_LATEX_ABS = strcat(PATH_SRC, 'latex/plots/static/tikz-data/');
oldpath = pwd;
[~, ~] = mkdir(PATH_MATLAB_RESULTS_ROOT, PATH_MATLAB_RESULTS_FOLDER_NAME);  % at least 2 argout's are required to suppress warning if dir already exists
cd(PATH_MATLAB_RESULTS);

% init filename
time_start = datestr(now(), 'yyyy-mm-dd-HH-MM-SS');
fname_base = sprintf('%s_sources_%d_mindistance_%0.1f_', time_start, n_sources, min_distance/10);
% init empty matrices
loc_err = zeros(trials, n_sources);
loc_est = zeros(trials, n_sources*2);
loc = zeros(trials, n_sources*2);
results = zeros(trials, n_sources*4+2);  % realX, realY, estX, estY, estErr1, estErr2
tic;

%% trials
for trial=1:trials
    cprintf('*blue', '   [Trial %d/%d]: %d sources, %1.2f minimal distance\n', trial, trials, n_sources, min_distance/10);
    evalc('config_update(n_sources, true, min_distance);');
    load('config.mat');
    [~, x] = evalc('simulate(ROOM, R, S);');
%     [x, ~] = simulate(ROOM, R, S);
    [~, X, phi] = evalc('stft(x);');
    cfg = set_params_evaluate_Gauss();
    [~, psi, est_error1, est_error2, loc_est1, loc_est2, fig] = evalc('bren_estimate_location(cfg, phi);');
    loc = reshape(S(:, 1:2)', 1, size(S, 1)*2);
    if trials>1
        loc_err(trial, :) = [est_error1, est_error2];
        loc_est(trial, :) = [loc_est1(1), loc_est1(2), loc_est2(1), loc_est2(2)];
    else
        loc_err = [est_error1, est_error2];
        loc_est = [loc_est1(1), loc_est1(2), loc_est2(1), loc_est2(2)];
    end
    %% print results
    for s=1:n_sources
        fprintf("%s Source Location #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f]\n", FORMAT_PREFIX, s, S(s,1:2), loc_est(trial, s*2-1), loc_est(trial, s*2));
    end
    fprintf("%s Estimation Error = [%0.2f, %0.2f] (Elapsed time = %0.2f)\n", FORMAT_PREFIX, est_error1, est_error2, toc');
    results(trial, :) = [loc, loc_est1(1), loc_est1(2), loc_est2(1), loc_est2(2), est_error1, est_error2];
    
    %% archive results
    fname_trial = sprintf('%strial_%d_of_%d_', fname_base, trial, trials);
    saveas(fig, strcat(fname_trial, 'fig.fig'), 'fig');
    matlab2tikz(strcat(PATH_SRC, '/latex/plots/static/', fname_trial, 'fig.tex'), 'figurehandle', fig, 'imagesAsPng', true, 'checkForUpdates', false, 'externalData', false, 'relativeDataPath', 'plots/static/tikz-data/', 'dataPath', PATH_LATEX_ABS, 'noSize', false, 'showInfo', false);
    close(fig);
    movefile('config.mat', strcat(fname_trial, 'config.mat'));
    
end

%% results
cprintf('*err', '   RESULT: mean error = %0.2f, max. error = %0.2f, min. error = %0.2f (time per trial = %0.2f, total = %0.2f)\n', mean(mean(loc_err)), max(max(loc_err)), min(min(loc_err)), toc'/trials, toc');
save(strcat(fname_base, 'results.mat'), 'results');
save(strcat(fname_base, 'results.txt'), 'results', '-ascii', '-double', '-tabs');
cd(oldpath);
end