%% EVALRUN_LNT evaluation script for LNT servers
% This script is called by |<../lntscripts/run_eval_local.sh run_eval_local.sh>|. First,
% it adds the |<../matlab/ matlab>| folder incl. its subfolders to the Matlab path.
% Second, the default random stream is reset, so trials on the same machine (started with
% a slight delay) have unique random values. Last, the parameter set is defined and the
% evaluation is run for 2 - 7 sources. Running trials for a range of parameter values can
% be done by adding an outer loop around the |n_sources| one.

%% REMOTE SERVER MATLAB CONFIG
% # Move from |<../matlab/localisation/evaluation/ evaluation>| subfolder to |<../matlab/
% matlab>| root
% # Add all subfolders in |<../matlab/ ./matlab/>| to MATLAB path
% # Reset random stream with clock-based seed
cd('../../.')
addpath_recurse;
rand('state',sum(100*clock));

%% DEFINE PARAMETER SET:
description='var-fixed'; % use only single quotes, double quotes will raise error in mkdir()
md = 5;
wd = 12;
rand_samples = true;
trials = [5 5];
T60=0.3;
SNR=0;
em_iterations=10;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
var_init=[2 3];
var_fixed=true;

%% EVALUATION TRIAL RUN
for i=1:length(var_init)
    for sources = 2:7
            random_sources_eval(description,sources,trials(i),md,wd,rand_samples,T60,SNR,em_iterations,em_conv_threshold,guess_randomly,reflect_order,var_init(i),var_fixed,'/HOMES/mainczyk/thesis/src/');
    end
end
