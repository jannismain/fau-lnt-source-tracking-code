function main(eval, trials, varargin)

clearvars('-except', 'eval', 'trials', 'varargin');
if nargin < 2, trials=100; end

switch eval
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
        
    case 'T60'
        description='T60';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=[0.3 0.9];
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        for i=1:length(T60)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60(i),SNR,em_iterations, em_conv_threshold, guess_randomly);
            end
        end
    
    case 'em-iterations'
        description='em-iterations';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.6;
        SNR=0;
        if ~(isempty(varargin))
            fprintf("WARN: User provided non-default evaluation parameter em_iterations = ");
            print_array(varargin{1}, "0.1f");
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

    case 'guessing'
        description='guessing';
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
        for sources = 2:7
            random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, reflect_order);
        end
    
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
        
    case 'min-distance'
        description='min-distance';  % use only single quotes, double quotes will raise error in mkdir()
        md = [1 3 5 10];
        wd = 12;
        rand_samples = true;
        T60=0.6;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        for i=1:length(md)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md(i),wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);  
            end
        end
    
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
            fprintf("WARN: User provided non-default evaluation parameter reflect_order = ");
            print_array(varargin{1}, "0.1f");
            reflect_order = varargin{1};
        else
            reflect_order=[-1 3 1];
        end
        for i=1:length(reflect_order)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, reflect_order(i));  
            end
        end
    
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
    
    otherwise
        cprintf('*err', 'This evaluation is not yet defined! Please check the spelling of "%s" or define "%s" as new evaluation!\n', eval, eval);
        
end