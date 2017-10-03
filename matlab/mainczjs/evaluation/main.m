%% Evaluation 1: 2/3/4 sources, 0.50m distance from each other, 1.20m distance from wall
trials = 20;
min_distance = 5;
distance_wall = 12;
for sources = 3:3
    results = random_sources_eval(sources,trials,min_distance,distance_wall);
end

%% Evaluation 2: 
