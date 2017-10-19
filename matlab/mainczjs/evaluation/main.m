%% Evaluation 1: BASE (randomised source samples, md=5, wd=12, em=5)
% for i=1:2
%     trials = 15;
%     min_distance = 5;
%     distance_wall = 12;
%     for sources = 2:7
%         results = random_sources_eval(sources,trials,min_distance,distance_wall,true,0.0,0,5);
%     end
% end

%% Evaluation 2: T60=0.3 (randomised source samples, md=5, wd=12, em=5)
% for i=1:5
%     trials = 20;
%     min_distance = 5;
%     distance_wall = 12;
%     for sources = 2:7
%         results = random_sources_eval(sources,trials,min_distance,distance_wall,true,0.3,0,5);
%     end
% end

%% Evaluation 3: T60=0.6 (randomised source samples, md=5, wd=12, em=5)
% for i=1:5
%     trials = 10;
%     min_distance = 5;
%     distance_wall = 12;
%     randomise_samples = true;
%     T60=0.6;
%     SNR=0;
%     em_iterations=5;
%     for sources = 2:7
%         results = random_sources_eval(sources,trials,min_distance,distance_wall,randomise_samples,T60,SNR,em_iterations);
%     end
% end

%% Evaluation 4: T60=0.6, EM=5 -> EM=10 (randomised source samples, md=5, wd=12, em=10)
for i=1:2
    trials = 25;
    min_distance = 5;
    distance_wall = 12;
    randomise_samples = true;
    T60=0.6;
    SNR=0;
    em_iterations=20;
    em_conv_threshold=-1;
    guess_randomly=false;
    description=sprintf('fixed-em-iterations-%d', em_iterations);  % use only single quotes, double quotes will raise error in mkdir()
    for sources = 2:7
        results = random_sources_eval(description,sources,trials,min_distance,distance_wall,randomise_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);
    end
end

%% Evaluation 5: Random Estimates
% description='guessing-at-random';  % use only single quotes, double quotes will raise error in mkdir()
% trials = 500;
% min_distance = 5;
% distance_wall = 12;
% randomise_samples = true;
% T60=0;
% SNR=0;
% em_iterations=0;
% em_conv_threshold=-1;
% guess_randomly=true;
% for sources = 1:10
%     results = random_sources_eval(description,sources,trials,min_distance,distance_wall,randomise_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);
% end

%% Evaluation 6: Plot improvement of location estimates for different em iteration steps
% for i=1:5
%     est_err(i, :) = single_example_eval();
%     i=i+1;
% end
