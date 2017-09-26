
function cfg = set_params_evaluate_Gauss()

load('config.mat');

cfg.c = c; % sound velocity
cfg.n_mic = n_receivers;
cfg.synth_room.mspacing = 0.2;
cfg.sig_len = sources.signal_length;
cfg.fs = fs;     % Sampling frequency for audio acquisition and playback
cfg.nsrc = n_sources;       % Number of sources

cfg.K = em.K;  % em.K

%% STFT parameters
cfg.wintime = fft_window_time;                            % (=fft_window_time) window length [s]
cfg.steptime = fft_step_time;                          % (=fft_step_time) frame shift [s]
cfg.winpts = fft_window_samples;        % (=fft_window_samples) window length [samples]
cfg.window = fft_window;             % (=fft_window) hanning window
cfg.steppts = fft_step_samples;      % (=fft_step_samples) frame shift [samples]
cfg.n_overlap = fft_overlap_samples;      % (=fft_overlap_samples) overlap of the windows [samples]
cfg.nfft = fft_bins;   % (=fft_bins) number of fft bins for STFT
cfg.n_bins = fft_bins_net;                     % (=fft_bins_net) number of non-redundant bins

% parameter settings for synthetic RIRs
cfg.synth_room.dim = room.dimensions;  % room dimensions [x, y, z]

cfg.synth_room.t60 = rir.t_reverb;       % reverberation time

cfg.synth_room.order = rir.reflect_order;        % reflections order of RIRs
cfg.synth_room.Nh = rir.length;         % length of RIRs
cfg.synth_room.height = 1;

%% Grid
cfg.mesh_res = 0.1;
cfg.N_margin = (1/cfg.mesh_res);  % +1, +2, ... does not solve issue with peaks at mesh borders, where mic pairs are located
cfg.mesh_x = room.grid_x;
cfg.mesh_y = room.grid_y;
[cfg.pos_x,cfg.pos_y] =  meshgrid(room.grid_x, room.grid_y);

cfg.X = length(cfg.mesh_x);
cfg.Y = length(cfg.mesh_y);

cfg.P = cfg.X*cfg.Y; % Number of Gridpoints

cfg.synth_room.src_paths = {'1.WAV',...
    '2.WAV',...
    '3.WAV',...
    'whitenoise3.wav'};

cfg.M = cfg.synth_room.Nh;  % rir.length
cfg.startIR = 1;   % cut impulse response from this sample...
cfg.endIR = cfg.M; % ... until this sample (0 to take the whole recorded RIR)

cfg.conv_thres = 0.01;  % EM convergence threshold


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% randomly set the source positions
% tmp_rand = 4*rand(2)+1;
% cfg.synth_room.sloc = [tmp_rand,cfg.synth_room.height*ones(cfg.nsrc,1)];         %sources location: X/Y/Z (sources height is fixed)
                       
% simSourceDist = 1;
% 
% sim_dim1 = cfg.synth_room.dim(1)-2.5;
% sim_dim2 = cfg.synth_room.dim(2)-2.5;
% cfg.synth_room.sloc(1,:) = [rand(1)*sim_dim1+1.25,rand(1)*sim_dim2+1.25,cfg.synth_room.height];
% cfg.synth_room.sloc(2,:) = [rand(1)*sim_dim1+1.25,rand(1)*sim_dim2+1.25,cfg.synth_room.height];
% while(norm(cfg.synth_room.sloc(1,:)-cfg.synth_room.sloc(2,:))<simSourceDist)
%     cfg.synth_room.sloc(2,:) = [rand(1)*sim_dim1+1.25,rand(1)*sim_dim2+1.25,cfg.synth_room.height];
% end

% cfg.source_pos_cart(3,:) = [rand(1)*sim_dim1+1,rand(1)*sim_dim2+1,cfg.synth_room.height];
% while((norm(cfg.source_pos_cart(3,:)-cfg.source_pos_cart(1,:))<simSourceDist) ||(norm(cfg.source_pos_cart(3,:)-cfg.source_pos_cart(2,:))<simSourceDist))
%     cfg.source_pos_cart(3,:) = [rand(1)*sim_dim1+1,rand(1)*sim_dim2+1,cfg.synth_room.height];
% end

% vonMises2
cfg.synth_room.sloc = S;

cfg.n_src = size(cfg.synth_room.sloc,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


shift_mic = 0;

% bottom
cfg.R = R;
x_posBottom = [2.2,2.8,3.8] -0.1;
cfg.synth_room.mloc(:,:,1) = [x_posBottom(1),1+shift_mic,cfg.synth_room.height;
    x_posBottom(1)+cfg.synth_room.mspacing,1,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,2) = [x_posBottom(2),1+shift_mic,cfg.synth_room.height;
    x_posBottom(2)+cfg.synth_room.mspacing,1,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,3) = [x_posBottom(3),1+shift_mic,cfg.synth_room.height;
    x_posBottom(3)+cfg.synth_room.mspacing,1,cfg.synth_room.height];

% right
y_posRight = [2.2,2.8,3.8];
cfg.synth_room.mloc(:,:,4) = [cfg.synth_room.dim(1)-1+shift_mic,y_posRight(1),cfg.synth_room.height;
    cfg.synth_room.dim(1)-1,y_posRight(1)+cfg.synth_room.mspacing,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,5) = [cfg.synth_room.dim(1)-1+shift_mic,y_posRight(2),cfg.synth_room.height;
    cfg.synth_room.dim(1)-1,y_posRight(2)+cfg.synth_room.mspacing,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,6) = [cfg.synth_room.dim(1)-1+shift_mic,y_posRight(3),cfg.synth_room.height;
    cfg.synth_room.dim(1)-1,y_posRight(3)+cfg.synth_room.mspacing,cfg.synth_room.height];


% above
x_posAbove = [2.2,3,3.8];
cfg.synth_room.mloc(:,:,7) = [x_posAbove(1)+cfg.synth_room.mspacing,cfg.synth_room.dim(2)-1,cfg.synth_room.height;
    x_posAbove(1),cfg.synth_room.dim(2)-1-shift_mic,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,8) = [x_posAbove(2)+cfg.synth_room.mspacing,cfg.synth_room.dim(2)-1,cfg.synth_room.height;
    x_posAbove(2),cfg.synth_room.dim(2)-1-shift_mic,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,9) = [x_posAbove(3)+cfg.synth_room.mspacing,cfg.synth_room.dim(2)-1,cfg.synth_room.height;
    x_posAbove(3),cfg.synth_room.dim(2)-1-shift_mic,cfg.synth_room.height];

% left
y_posLeft = [2.2,3,3.8] - 0.1;
cfg.synth_room.mloc(:,:,10) = [1,y_posLeft(1)+cfg.synth_room.mspacing,cfg.synth_room.height;
    1-shift_mic,y_posLeft(1),cfg.synth_room.height];

cfg.synth_room.mloc(:,:,11) = [1,y_posLeft(2)+cfg.synth_room.mspacing,cfg.synth_room.height;
    1-shift_mic,y_posLeft(2),cfg.synth_room.height];

cfg.synth_room.mloc(:,:,12) = [1,y_posLeft(3)+cfg.synth_room.mspacing,cfg.synth_room.height;
    1-shift_mic,y_posLeft(3),cfg.synth_room.height];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.n_pairs = size(cfg.synth_room.mloc,3);

cfg.synth_room.mloc_center = zeros(size(cfg.synth_room.mloc,3),3);
for idx_mPairs = 1:cfg.n_pairs
    cfg.synth_room.mloc_center(idx_mPairs,:) = [mean(cfg.synth_room.mloc(:,1:2,idx_mPairs),1), cfg.synth_room.height];
end

% Add some noise
cfg.noise_type = 0;
% 0 = no noise
% 1 = white noise
switch cfg.noise_type
    case 0 % no noise
    case 1 % white noise
        cfg.inputsnr = 30; % input SNR in dB
    otherwise
        error('Invalid choice of the variable cfg.noise_type\n');
end

end



