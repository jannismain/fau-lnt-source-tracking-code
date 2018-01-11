function main(eval, trials, varargin)
%% MAIN repository for evaluation trials
% This function provides several different evaluation trials.
%
% *Example:* To run an evaluation trial with $$ n = 50 $$ for $$ T_{60} \in \{0.0, 0.3,
% 0.6, 0.9\} $$, one could enter the following command:
%
%   >> main('T60', 50)
% 

%% Arguments
% * *eval (str)*: name of evaluation trial to run _(required)_
% * *trials (int)*: number of trials to run _(default: *100*)_
% * *varargin (cell array)*: variable additional arguments _(i.e. used to provide non-default max. em-iteration range for |em-iteration| trial)_
clearvars('-except', 'eval', 'trials', 'varargin');
if nargin < 2, trials=100; end

%% Evaluation Trials
switch eval
    %% BASE EVALUATION
    case 'base'
        description='base';  % use only single quotes, double quotes will raise error in mkdir()
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=3;
        for sources = 2:7
            random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order);
        end
        
    %% T60 EVALUATION
    case 'T60'
        description='T60';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=[0.0 0.3 0.6 0.9];
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        trials=[150,150,150];
        r=-1;
        var_init=0.1;
        var_fixed=false;
        for i=1:length(T60)
            for sources = 2:7
                random_sources_eval(description,sources,trials(i),md,wd,rand_samples,T60(i),SNR,em_iterations, em_conv_threshold, guess_randomly, r,var_init, var_fixed);
            end
        end
    %% EM-ITERATIONS EVALUATION
    case 'em-iterations'
        description='em-iterations';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.6;
        SNR=0;
        if ~(isempty(varargin))
            fprintf('WARN: User provided non-default evaluation parameter em_iterations = ');
            print_array(varargin{1}, '0.1f');
            em_iterations = varargin{1};
        else
            em_iterations=[1 5 10 20];
        end
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=3;
        for em=1:length(em_iterations)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations(em), em_conv_threshold, guess_randomly, reflect_order);
            end
        end
    %% GUESSING EVALUATION
    case 'guessing'
        description='_guessing';  % underscore used to exclude directory from being loaded into python by default
        trials=250;
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=0;
        em_conv_threshold=-1;
        guess_randomly=true;
        reflect_order=3;
        var_init=0.1;
        var_fixed=false;
        for sources = 2:7
            random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, reflect_order);
        end
    %% GUESSING EVALUATION (with alternative error calculation)
    case 'guessing_alt_err'
        description='guessing_alt_err';
        trials=500;
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=0;
        em_conv_threshold=-1;
        guess_randomly=true;
        reflect_order=-1;
        var_init=0.1;
        var_fixed=false;
        alt_err = true;
        for sources = 8:9
            random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, reflect_order, var_init, var_fixed, false, alt_err);
        end
    %% SINGLE EXAMPLE EVALUATION
    case 'em-single'
        sources=4;
        md = 5;
        wd = 12;
        rand_sources = true;
        T60=0.0;
        em_iterations=50;
        em_conv_threshold=-1;
        for i=1:5
            est_err(i, :) = single_example_eval(sources,rand_sources, md, wd, T60, em_iterations, em_conv_threshold);
        end
    %% MIN-DISTANCE EVALUATION
    case 'min-distance'
        description='min-distance';  % use only single quotes, double quotes will raise error in mkdir()
        md = [3 5 10];
        wd = 12;
        rand_samples = true;
        T60=0.3;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        sources_trial = [6 6 5];
        trials = [100 200 100];
        guess_randomly=false;
        r=3;
        var_init=0.1;
        var_fixed=false;
        for i=1:length(md)
            for sources = sources_trial(i):7
                random_sources_eval(description,sources,trials(i),md(i),wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, r,var_init, var_fixed);
            end
        end
    %% REFLECT-ORDER EVALUATION
    case 'reflect-order'
        description='reflect-order';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        if ~(isempty(varargin))
            fprintf('WARN: User provided non-default evaluation parameter reflect_order = ');
            print_array(varargin{1}, '0.1f');
            reflect_order = varargin{1};
        else
            reflect_order=[-1 3 1];
        end
        for i=1:length(reflect_order)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, reflect_order(i));
            end
        end
    %% NOISE EVALUATION
    case 'noise'
        description='noise';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.6;
        SNR=[15 30];
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=-1;
        for i=1:length(SNR)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR(i),em_iterations, em_conv_threshold, guess_randomly, reflect_order);
            end
        end
    %% WALL-DISTANCE EVALUATION
    case 'wd'
        description='wd';  % perfect conditions, increased wd, trying to get 100% success rate!
        md = 5;
        wd = [12, 13, 15];
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=0;
        for i=1:length(wd)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd(i),rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order);
            end
        end
    %% INITIAL VARIANCE EVALUATION
    case 'var'
        description='var';  % test fixed variance with different values
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.3;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=3;
        variance=[0.1 0.5 1];
        for i=1:length(variance)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,variance(i));
            end
        end
    %%
    otherwise
        %% Unknown Evaluation Name
        cprintf('*err', 'This evaluation is not yet defined! Please check the spelling of "%s" or define "%s" as new evaluation!\n', eval, eval);

end
