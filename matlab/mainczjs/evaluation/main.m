function main(eval, trials)

clearvars('-except', 'eval', 'trials');
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
        for sources = 2:7
            random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);
        end
        
    case 'T60'
        description='T60';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=[0.3 0.6 0.9];
        SNR=0;
        em_iterations=10;
        em_conv_threshold=-1;
        guess_randomly=false;
        for i=1:3
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60(i),SNR,em_iterations, em_conv_threshold, guess_randomly);
            end
        end
    
    case 'em_iterations'
        description='em-iterations';
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.6;
        SNR=0;
        em_iterations=[5 10 20 50];
        em_conv_threshold=-1;
        guess_randomly=false;
        for em=1:4
            for sources = 2:7
                random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations(em), em_conv_threshold, guess_randomly);
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
        for sources = 2:7
            random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);
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
        
    case 'min-distance-T60-0.3'
        description='min-distance';  % use only single quotes, double quotes will raise error in mkdir()
        md = [1 3 5 10];
        wd = 12;
        rand_samples = true;
        T60=0.3;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        for i=1:length(md)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md(i),wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);  
            end
        end
        
    case 'min-distance-T60-0.0'
        description='min-distance';  % use only single quotes, double quotes will raise error in mkdir()
        md = [1 3 5 10];
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        for i=1:length(md)
            if i==1, min_s = 5; else, min_s = 2; end
            for sources = min_s:7
                random_sources_eval(description,sources,trials,md(i),wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly);  
            end
        end
    
    case 'reflect-order'
        description='reflect_order';  % use only single quotes, double quotes will raise error in mkdir()
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=[-1];
        for i=1:length(reflect_order)
            for sources = 2:7
                random_sources_eval(description,sources,trials,md(i),wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly, reflect_order(i));  
            end
        end
    
    otherwise
        cprintf('*err', 'This evaluation is not yet defined! Please check the spelling of "%s" or define "%s" as new evaluation!\n', eval, eval);
        
end