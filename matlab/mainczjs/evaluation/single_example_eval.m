function [ est_err ] = single_example_eval(n_sources, random_sources, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed)

if nargin < 1, n_sources = 7; end
if nargin < 2, random_sources = true; end
if nargin < 3, min_distance = 5; end
if nargin < 4, distance_wall = 12; end
if nargin < 5, randomize_samples = true; end
if nargin < 6, T60 = 0.6; fprintf('WARNING: Using default for T60 (0.3)\n'); end
if nargin < 7, em_iterations = 6; fprintf('WARNING: Using default for em_iterations (10)\n'); end
if nargin < 8, em_conv_threshold = -1; fprintf('WARNING: Using default for em_conv_threshold (-1)\n'); end
if nargin < 9, reflect_order = -1; fprintf('WARNING: Using default for rir-reflect_order (3)\n'); end
if nargin < 10, SNR = 10; fprintf('WARNING: Using default for SNR (0)\n'); end
if nargin < 11, var_init = 0.1; end
if nargin < 12, var_fixed = false; end

%% Setup Environment
fprintf('--------------------- E V A L U A T I O N ---------------------\n');
tic;
err = 0;

%% Testrun
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

if err>0
    fprintf("Will generate new data\n");
    fn_cfg = config_update(n_sources, random_sources, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed);
    load(fn_cfg);
    x = simulate(fn_cfg, ROOM, R, sources);
    [~, phi] = stft(fn_cfg, x);
    [psi, iter, variance] = em_algorithm(fn_cfg, phi, em_iterations, em_conv_threshold, true);
    delete('config*.mat')
    save('analysis.mat');
end

%% Visualise Results
% variant 1
analyse_em_steps(psi, variance, min_distance, room);


%% End
fprintf('\n---------------------   E N D   ---------------------\n');