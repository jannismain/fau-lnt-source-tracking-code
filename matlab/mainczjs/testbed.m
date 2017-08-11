%% Setup Environment
config_update;
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% Simulate Environment
[y, fig] = simulate(ROOM, R, S);

%% Calculate STFT
y_hat = stft(y);

%% Calculate DOA
doa = doa_from_stft(y_hat, fig);

% load('y_hat.mat');
% save('y_hat.mat', 'y_hat');

%% Debugging
% size(doa);
% doa_vec = reshape(doa(1,:,:), [size(doa, 2)*size(doa, 3) 1]);
% nansum(doa_vec)/nansum(doa_vec~=0);
% % nansum(doa_vec~=pi && doa_vec ~= 0);
% doa_not_pi = sum(doa_vec~=pi);
% doa_zero = sum(doa_vec == 0);
% size(doa_vec, 1);

%% EM-Algorithm
em_algorithm(y_hat, fig);

%% End
cprintf('err', '\n---------------------   E N D   ---------------------\n');