function [x, S_data] = simulate_tracking(force_rir)
% SIMULATE Simulates a room with two audio sources and receivers and
% generates the received signal at both receivers
%
% NOTES:
%   - Time will always be given in seconds [s] unless otherwise noted
%     (e.g. [ms])
%
%

%% START
fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);
load('config.mat')

if nargin<1, force_rir=false; end

%% Load source data...
m = sprintf("Load source data... (t = %2.4f)", toc); counter = next_step(m, counter);
    
    S_data = zeros(source_length*fs, n_sources);
    for s = 1:n_sources
        [temp, fs_temp] = audioread(sources.samples(s, :));
        if fs_temp ~= fs
            temp = resample(temp, fs, fs_temp);
            if room.snr>0
                temp = awgn(temp, SNR, 'measured');
            end
        end
        S_data(1:source_length*fs, s) = temp(1:source_length*fs);
    end

%% Calculate RIR-bank
if strcmp(method, 'fastISM')
m = sprintf("Calculate RIR for each Source-Receiver combination... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NODEF>
    fn_rir = [];
    for s = 1:n_sources
        config_shift_current_trajectory(s)
        fn_path_rirs = [getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'ress' filesep 'rir' filesep];
        fn = sprintf('RIRs_[%d,%d]_to_[%d,%d]_T60=%0.1f_s=%d.mat', sources.positions(s, 1), sources.positions(s, 2), sources.positions(s, 1)+sources.movement(s, 1), sources.positions(s, 2)+sources.movement(s, 2),rir.t_reverb,samples);
        fn_rir = [fn_rir; [fn_path_rirs, fn]];
        if exist(fn_rir(s,:),'file')~=2 || force_rir
            fast_ISM_RIR_bank(custom_ISM_setup,fn_rir(s,:));
        else
            fprintf("%s Will use existing RIR-Bank: '%s' (t=%2.2f)\n", FORMAT_PREFIX, fn_rir(s,:), toc);
        end
    end
end

%% Create Received Signals
m = sprintf("Mixing Signals... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NASGU>
    for s=1:n_sources
        if strcmp(method, 'fastISM')
            %% Use fastISM by Lehmann
            source_data = ISM_AudioData(fn_rir(s,:),S_data(:, s));
            if s==1
                x = zeros(size(source_data, 1), n_sources,2, size(source_data, 2)/2);
            end
            % reshape data to fit [:,s,mic,mic_pair] structure
            for i=1:size(source_data, 2)
                mic = 2-mod(i,2);
                mic_pair = roundn(i/2,0);
                x(:,s,mic,mic_pair) = source_data(:,i);
            end
            
        elseif strcmp(method, 'siggen')
            %% Use Signal-Generator by Habets
            siglen = size(S_data, 1);
            x = zeros(siglen, sources.n,2,room.R_pairs);
            r_path = zeros(siglen, size(room.R, 2), size(room.R, 1));
            s_path = get_trajectory_from_source(squeeze(S(s,:)),squeeze(sources.movement(s,:)), siglen);
            for r=1:siglen
                r_path(r, :, :) = room.R';
            end
            source_data = signal_generator(S_data(:,s)',room.c,fs,r_path,s_path,room.dimensions,rir.t_reverb,rir.length,'o',rir.reflect_order);
            % reshape data to fit [:,s,mic,mic_pair] structure
            for i=1:size(source_data, 1)
                mic = 2-mod(i,2);
                mic_pair = roundn(i/2,0);
                x(:,s,mic,mic_pair) = squeeze(source_data(i,:));
            end
        end
    end
    m = sprintf("Mixing Signals... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NASGU>
    x = squeeze(sum(x, 2));
    sound(x(:,1,1), 16000)
end