
function cfg = set_params_ASN_GMM_tracking(cfg)

cfg.c = 343; % sound velocity
cfg.n_mic = 2;
cfg.synth_room.mspacing = 0.2;
cfg.sig_len = 5;
cfg.fs = 16000;     % Sampling frequency for audio acquisition and playback
cfg.nsrc = 2;       % Number of sources

%% Settings
cfg.hop = 100;                        % Refresh rate of the AIR
cfg.synth_room.height = 1;

cfg.type_of_movement = 'arc';       % Source movement 'arc' or 'line'
switch lower(cfg.type_of_movement)
    case 'arc'
        cfg.synth_room.sloc_start = [3, 1.5,cfg.synth_room.height;
            3, 4.5,cfg.synth_room.height];                % Initial source position
        cfg.stop_x = [3,3];
        cfg.stop_y = [4.5,1.5];
    case 'line'
        cfg.synth_room.sloc_start = [2, 1,cfg.synth_room.height;
            4, 5,cfg.synth_room.height];                % Initial source position
        cfg.stop_x = [2,4];
        cfg.stop_y = [5,1];
    case 'single_line'
        cfg.synth_room.sloc_start = [2, 1,cfg.synth_room.height];                % Initial source position
        cfg.stop_x = 2;
        cfg.stop_y = 5;
        
        cfg.nsrc = 1;
end
cfg.mov_angle = 180;
cfg.K = length(cfg.freq_range);

%% STFT parameters
cfg.wintime = 0.05;                     % window length [s]
cfg.steptime = 0.010;                    % frame shift [s]
cfg.winpts = round(cfg.wintime*cfg.fs);          % window length [samples]
cfg.window = hanning(cfg.winpts)';           % hanning window
cfg.steppts = round(cfg.steptime*cfg.fs);        % frame shift [samples]
cfg.n_overlap = cfg.winpts - cfg.steppts;        % overlap of the windows [samples]
cfg.nfft = 2^(ceil(log(cfg.winpts)/log(2))); % number of fft bins for STFT
cfg.n_bins = cfg.nfft/2+1;                 % number of non-redundant bins
cfg.freq = ((0:cfg.nfft/2)/cfg.nfft*cfg.fs).';           % frequency vector [Hz]

% parameter settings for synthetic RIRs
cfg.synth_room.dim = [6, 6, 6.1];  % room dimensions [x, y, z]

% Reverb1
cfg.synth_room.t60 = 0.3;       % reverberation time
% % Reverb2
% cfg.synth_room.t60 = 0.6;       % reverberation time

cfg.synth_room.order = 3;        % reflections order of RIRs
cfg.synth_room.Nh = 8*1024;         % length of RIRs

%% Grid
cfg.mesh_res = 0.1;
cfg.N_margin = 1/cfg.mesh_res;
cfg.mesh_x = (0:cfg.mesh_res:cfg.synth_room.dim(1));
cfg.mesh_y = (0:cfg.mesh_res:cfg.synth_room.dim(2));
[cfg.pos_x,cfg.pos_y] =  meshgrid(cfg.mesh_x,cfg.mesh_y);

cfg.X = length(cfg.mesh_x);
cfg.Y = length(cfg.mesh_y);

cfg.P = cfg.X*cfg.Y; % Number of Gridpoints

cfg.n_src = size(cfg.synth_room.sloc_start,1);

cfg.synth_room.src_paths = {'1.WAV',...
    '2.WAV',...
    '3.WAV',...
    'whitenoise3.wav'};

cfg.M = cfg.synth_room.Nh;
cfg.startIR = 1;   % cut impulse response from this sample...
cfg.endIR = cfg.M; % ... until this sample (0 to take the whole recorded RIR)

% bottom
x_posBottom = [2.2,2.8,3.8] -0.1;
cfg.synth_room.mloc(:,:,1) = [x_posBottom(1),1,cfg.synth_room.height;
    x_posBottom(1)+cfg.synth_room.mspacing,1,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,2) = [x_posBottom(2),1,cfg.synth_room.height;
    x_posBottom(2)+cfg.synth_room.mspacing,1,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,3) = [x_posBottom(3),1,cfg.synth_room.height;
    x_posBottom(3)+cfg.synth_room.mspacing,1,cfg.synth_room.height];

% right
y_posRight = [2.2,2.8,3.8];
cfg.synth_room.mloc(:,:,4) = [cfg.synth_room.dim(1)-1,y_posRight(1),cfg.synth_room.height;
    cfg.synth_room.dim(1)-1,y_posRight(1)+cfg.synth_room.mspacing,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,5) = [cfg.synth_room.dim(1)-1,y_posRight(2),cfg.synth_room.height;
    cfg.synth_room.dim(1)-1,y_posRight(2)+cfg.synth_room.mspacing,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,6) = [cfg.synth_room.dim(1)-1,y_posRight(3),cfg.synth_room.height;
    cfg.synth_room.dim(1)-1,y_posRight(3)+cfg.synth_room.mspacing,cfg.synth_room.height];


% above
x_posAbove = [2.2,3,3.8];
cfg.synth_room.mloc(:,:,7) = [x_posAbove(1)+cfg.synth_room.mspacing,cfg.synth_room.dim(2)-1,cfg.synth_room.height;
    x_posAbove(1),cfg.synth_room.dim(2)-1,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,8) = [x_posAbove(2)+cfg.synth_room.mspacing,cfg.synth_room.dim(2)-1,cfg.synth_room.height;
    x_posAbove(2),cfg.synth_room.dim(2)-1,cfg.synth_room.height];

cfg.synth_room.mloc(:,:,9) = [x_posAbove(3)+cfg.synth_room.mspacing,cfg.synth_room.dim(2)-1,cfg.synth_room.height;
    x_posAbove(3),cfg.synth_room.dim(2)-1,cfg.synth_room.height];

% left
y_posLeft = [2.2,3,3.8] - 0.1;
cfg.synth_room.mloc(:,:,10) = [1,y_posLeft(1)+cfg.synth_room.mspacing,cfg.synth_room.height;
    1,y_posLeft(1),cfg.synth_room.height];

cfg.synth_room.mloc(:,:,11) = [1,y_posLeft(2)+cfg.synth_room.mspacing,cfg.synth_room.height;
    1,y_posLeft(2),cfg.synth_room.height];

cfg.synth_room.mloc(:,:,12) = [1,y_posLeft(3)+cfg.synth_room.mspacing,cfg.synth_room.height;
    1,y_posLeft(3),cfg.synth_room.height];

cfg.n_pairs = size(cfg.synth_room.mloc,3);

cfg.synth_room.mloc_center = zeros(size(cfg.synth_room.mloc,3),3);
for idx_mPairs = 1:cfg.n_pairs
    cfg.synth_room.mloc_center(idx_mPairs,:) = [mean(cfg.synth_room.mloc(:,1:2,idx_mPairs),1), cfg.synth_room.height];
end


end



