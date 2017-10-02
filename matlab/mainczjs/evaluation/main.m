%% Evaluation 1: 2 sources, 0.50m distance from each other, 1.20m distance from wall
trials = 2;
sources = 2;
min_distance = 5;
distance_wall = 12;
results = random_sources_eval(sources,trials,min_distance,distance_wall);

% %% Evaluation 1: 3 sources, 0.50m minimal distance
% trials = 100;
% sources = 3;
% min_distance = 5;
% loc_err = random_sources_eval(sources,trials,min_distance);