function [results] = random_sources_eval(n_sources, trials, min_distance)
% TODO: after bren_location_estimate has been dealt with, truly parameterise for n sources (right now only 2 are supported)

%% function argument handling
if nargin < 1
    n_sources = 2;
end
if nargin < 2
    trials = 10;
end
if nargin < 3
    min_distance = 0.5;
end

%% initialisation
cprintf('-comment', '                E V A L U A T I O N                \n');
loc_err = zeros(trials, n_sources);
loc_est = zeros(trials, n_sources*2);
loc = zeros(trials, n_sources*2);
results = zeros(trials, n_sources*4+2);  % realX, realY, estX, estY, estErr1, estErr2

%% trials
for trial=1:trials
    cprintf('*blue', '   [Trial %d/%d]: %d sources, %1.2f minimal distance\n', trial, trials, n_sources, min_distance/10);
    tic;
    log_cfg_update = evalc('config_update(n_sources, true, min_distance);');
    load('config.mat');
    [log_simulate, x, fig] = evalc('simulate(ROOM, R, S);');
%     [x, fig] = simulate(ROOM, R, S);
    [log_stft, X, phi] = evalc('stft(x);');
    cfg = set_params_evaluate_Gauss();
    subplot_tight(2,2,[2 4], PLOT_BORDER);
    [log_est_loc, psi, est_error1, est_error2, loc_est1, loc_est2] = evalc('bren_estimate_location(cfg, phi);');
    if trials>1
        loc = reshape(S(:, 1:2)', 1, size(S, 1)*2);
        loc_err(trial, :) = [est_error1, est_error2];
        loc_est(trial, :) = [loc_est1(1), loc_est1(2), loc_est2(1), loc_est2(2)];
        
    else
        loc_err = [est_error1, est_error2];
    end
    % print output
    for s=1:n_sources
        fprintf("%s Source Location #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f]\n", FORMAT_PREFIX, s, S(s,1:2), loc_est(trial, s*2-1), loc_est(trial, s*2));
    end
    fprintf("%s Estimation Error = [%0.2f, %0.2f]\n", FORMAT_PREFIX, est_error1, est_error2)
    results(trial, :) = [loc, loc_est1(1), loc_est1(2), loc_est2(1), loc_est2(2), est_error1, est_error2];
end

%% results
cprintf('*err', '   RESULT: mean error = %0.2f, max. error = %0.2f, min. error = %0.2f (Total Runtime = %s)\n', mean(mean(loc_err)), max(max(loc_err)), min(min(loc_err)), num2str(toc)');

end