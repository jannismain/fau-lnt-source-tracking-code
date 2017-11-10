function [ est_err ] = single_example_eval(n_sources, rand_sources, md, wd, T60, max_em_iterations, em_conv_threshold, phi)

%% Setup Environment
fprintf('--------------------- E V A L U A T I O N ---------------------\n');
tic;


%% Testrun
if exist('phi', 'var')==1
    fprintf("Will analyze data from prior simulation");
    load('config', 'room')
elseif exist('phi.mat','file')==2 && exist('config.mat','file')==2
    fprintf("Will analyze data from prior simulation");
    load('phi.mat');
    load('config', 'room')
else
    config_update(n_sources, rand_sources, md, wd, true, T60, max_em_iterations, em_conv_threshold)
    load('config.mat');
    x = simulate(ROOM, R, sources);
    [~, phi] = stft(x);
    save('phi.mat', 'phi');
end

if exist('mainczjs/psi.mat','file')==2
    load('mainczjs/psi.mat');
else
    [psi, iter] = em_algorithm(phi, max_em_iterations, em_conv_threshold, true);
    save('psi.mat', 'psi');
end

%% Visualise Results
% variant 1
analyse_em_steps(psi, n_sources, md, room);

%% End
fprintf('\n---------------------   E N D   ---------------------\n');