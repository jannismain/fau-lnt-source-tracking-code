function random_sources_eval = random_sources_eval(n_sources, trials, min_distance)
tic;

if nargin < 1
    n_sources = 2;
end
if nargin < 2
    trials = 10;
end
if nargin < 3
    min_distance = 0.5;
end

loc_err = zeros(trials, n_sources);

for trial=1:trials
    config_update(n_sources, true, min_distance);
    load('config.mat');
    [x, fig] = simulate(ROOM, R, S);
    [X, phi] = stft(x);
    cfg = set_params_evaluate_Gauss();
    subplot_tight(2,2,[2 4], PLOT_BORDER);
    [psi, est_error1, est_error2] = bren_estimate_location(cfg, phi);
    if trials>1
        loc_err(trial, :) = [est_error1, est_error2];
    else
        loc_err = [est_error1, est_error2];
    end
end

random_sources_eval = mean(loc_err, 1);

end