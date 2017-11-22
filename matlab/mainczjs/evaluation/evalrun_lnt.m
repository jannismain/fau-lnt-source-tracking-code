% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse  % ensure all folders are added to path
rand('state',sum(100*clock));
dir = '/HOMES/mainczyk/thesis/src/';

% EVALUATION ROUTINE:
description='psi_s';
md = 5;
wd = 12;
rand_samples = true;
T60=0.3;
SNR=0;
em_iterations=5;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
trials=25;
var_init = 0.1;
var_fixed = false;
prior=[string('equal'), string('rand'), string('hh'), string('quart')]; %#ok<STRQUOT> string creation with "..." is not allowed on LNT Matlab.
for p=1:length(prior)
    if strcmp(prior(p), string('equal')), minS = 6; else, minS = 2; end
    for sources = minS:7
        random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,var_init,var_fixed,dir,prior(p));
    end
end
