function [ est_err ] = single_example_eval(n_sources, random_sources, min_distance, distance_wall, randomise_samples, T60, em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed)
%% SINGLE_EXAMPLE_EVAL Run single evaluation trial
% This function can be used to run a single evaluation trial without the file management 
% overhead of |<./random_sources_eval.html random_sources_eval>|. It also provides the
% ability to load and use intermediary results from previous trials, if they are
% accessible either in the current workspace or saved as |mat| file.

%% Arguments
% * *n_sources (int)*: _number of sources to be simulated (default: *2*)_
% * *random_sources (bool)*: _chose random source locations (default: *true*)_
% * *min_distance (int)*: _minimum required distance between sources (in decimetre, default: *5*)_
% * *distance_wall (int)*: _minimum required distance of sources from wall (in decimetre, default: *12*)_
% * *randomise_samples (bool)*: _description (comment, default: *true*)_
% * *T60 (double)*: _reverberation time (in seconds, default: *0.3*)_
% * *em_iterations (int)*: _number of maximum em iterations (default: *5*)_
% * *em_conv_threshold (int)*: _convergence threshold for em algorithm (-1 equals no threshold, default: *-1*)_
% * *reflect_order (int)*: _maximum reflection order for image-method simulation (-1 equals max, default: *3*)_
% * *SNR (int)*: _amount of noise added to received signal (in dB, 0 equals no noise, default: *0*)_
% * *var_init (double)*: _initial value for variance (default: *0.1*)_
% * *var_fixed (bool)*: _do not estimate variance for each em iteration (default: *false*)_

if nargin < 1, n_sources = 2; end
if nargin < 2, random_sources = true; end
if nargin < 3, min_distance = 5; end
if nargin < 4, distance_wall = 12; end
if nargin < 5, randomise_samples = true; end
if nargin < 6, T60 = 0.3; fprintf('WARNING: Using default for T60 (0.3)\n'); end
if nargin < 7, em_iterations = 5; fprintf('WARNING: Using default for em_iterations (5)\n'); end
if nargin < 8, em_conv_threshold = -1; fprintf('WARNING: Using default for em_conv_threshold (-1)\n'); end
if nargin < 9, reflect_order = 3; fprintf('WARNING: Using default for rir-reflect_order (3)\n'); end
if nargin < 10, SNR = 0; fprintf('WARNING: Using default for SNR (0)\n'); end
if nargin < 11, var_init = 0.1; fprintf('WARNING: Using default initial variance (0.1)\n'); end
if nargin < 12, var_fixed = false; fprintf('WARNING: Using default for var_fixed (false)\n'); end

%% Initialisation
cprintf('-comment', '                            E V A L U A T I O N                            \n');
tic;
err = 0;

%% Try to Load Existing, Intermediary Results
% This provides a huge benefit during development, as runtime is decreased when reusing
% already calculated results. NOTE: This has do be adjusted for debugging specific parts
% of the processing chain.
try
    phi = evalin('base', 'phi');
    room = evalin('base', 'room');
    S = evalin('base', 'S');
    room.S = S;
    psi = evalin('base', 'psi');
    n_sources = evalin('base', 'n_sources');
    min_distance = evalin('base', 'min_distance');
    variance = evalin('base', 'variance');
    if size(psi, 3)==1, error("psi does not include full history!"), end
    fprintf("Will analyze workspace data\n");
catch
    err = err+1;
end
    
if err==1 
    try
        w = what(); w = w.mat;
        if length(w)==2
            for i=1:length(w)
                load(string(w(i)));
            end
        else
            error("No saved data found!")
        end
        fprintf("Will analyze saved data\n");
        err=0;
    catch
        err = err+1;
    end
end
%% Generate New Data
if err>0
    fprintf("Will generate new data\n");
    fn_cfg = config_update(n_sources, random_sources, min_distance, distance_wall, randomise_samples, T60, em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed);
    load(fn_cfg);
    x = simulate(fn_cfg, ROOM, R, sources);
    [~, phi] = stft(fn_cfg, x);
    [psi, iter, variance] = em_algorithm(fn_cfg, phi, em_iterations, em_conv_threshold, true);
    delete('config*.mat');
    save('analysis.mat');
end

%% Visualise Results
analyse_em_steps(psi, variance, min_distance, room);
end