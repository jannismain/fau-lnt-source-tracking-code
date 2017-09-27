%% Evaluation 1: 2 sources, 0.50m minimal distance
trials = 2;
sources = 2;
min_distance = 5;
results = random_sources_eval(sources,trials,min_distance);

% %% Evaluation 1: 3 sources, 0.50m minimal distance
% trials = 100;
% sources = 3;
% min_distance = 5;
% loc_err = random_sources_eval(sources,trials,min_distance);

% TODO: make evaluation truly independent from number of sources