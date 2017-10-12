%% Evaluation 1: 2-7 sources, 0.50m distance from each other, 1.20m distance from wall
trials = 10;
min_distance = 5;
distance_wall = 12;
for sources = 2:7
    results = random_sources_eval(sources,trials,min_distance,distance_wall);
end

%% Evaluation 2: 2-7 sources, 0.50m distance from each other, 1.20m distance from wall
% trials = 50;
% min_distance = 5;
% distance_wall = 12;
% for sources = 2:7
%     results = random_sources_eval(sources,trials,min_distance,distance_wall);
% end
