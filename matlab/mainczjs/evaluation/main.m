%% Evaluation 1: BASE (randomised source samples, md=5, wd=12, em=5)
trials = 45;
min_distance = 5;
distance_wall = 12;
for sources = 2:5
    results = random_sources_eval(sources,trials,min_distance,distance_wall,true,0.0,0,5);
end

%% Evaluation 2: T60=0.3 (randomised source samples, md=5, wd=12)
% trials = 20;
% min_distance = 5;
% distance_wall = 12;
% for sources = 2:5
%     results = random_sources_eval(sources,trials,min_distance,distance_wall,true,0.3,0,5);
% end

%% Evaluation 3: T60=0.6 (randomised source samples, md=5, wd=12)
% trials = 20;
% min_distance = 5;
% distance_wall = 12;
% for sources = 2:5
%     results = random_sources_eval(sources,trials,min_distance,distance_wall,true,0.6,0,5);
% end
