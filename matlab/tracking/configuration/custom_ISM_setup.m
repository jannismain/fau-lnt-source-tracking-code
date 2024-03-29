function [SetupStruc] = custom_ISM_setup()
%ISM_setup  Environmental parameters for image-source method simulation
%
% [SetupStruc] = ISM_setup()  
%
% This function can be used as a template for the definition of the
% different parameters for an image-source method simulation, typically
% providing inputs to the functions 'ISM_RIR_bank.m' as well as
% 'fast_ISM_RIR_bank.m' (Lehmann & Johansson's ISM implementations). This
% function returns the structure 'SetupStruc' with the following fields:
%
%          Fs: sampling frequency in Hz.
%        room: 1-by-3 vector of enclosure dimensions (in m), 
%              [x_length y_length z_length].
%     mic_pos: N-by-3 matrix, [x1 y1 z1; x2 y2 z2; ...] positions of N
%              microphones in the environment (in m). 
%    src_traj: M-by-3 matrix, [x1 y1 z1; x2 y2 z2; ...] positions of M 
%              source trajectory points in the environment (in m).
%  T20 or T60: scalar value (in s), desired reverberation time.
%           c: (optional) sound velocity (in m/s).
% abs_weights: (optional) 1-by-6 vector of absorption coefficients weights, 
%              [w_x1 w_x2 w_y1 w_y2 w_z1 w_z2].
%
% The structure field 'c' is optional in the sense that the various
% functions developed in relation to Lehmann & Johansson's ISM
% implementation assume a sound velocity of 343 m/s by default. If defined
% in the function below, the field 'SetupStruc.c' will take precedence and
% override the default value with another setting.
%
% The field 'abs_weight' corresponds to the relative weights of each of the
% six absorption coefficients resulting from the desired reverberation time
% T60. For instance, defining 'abs_weights' as [0.8 0.8 1 1 0.6 0.6] will
% result in the absorption coefficients (alpha) for the walls in the
% x-dimension being 20% smaller compared to the y-dimension walls, whereas
% the floor and ceiling will end up with absorption coefficients 40%
% smaller (e.g., to simulate the effects of a concrete floor and ceiling).
% Note that setting some of the 'abs_weight' parameters to 1 does NOT mean
% that the corresponding walls will end up with a total absorption! If the
% field 'abs_weight' is omitted, the various functions developed in
% relation to Lehmann & Johansson's ISM implementation will set the
% 'abs_weight' parameter to [1 1 1 1 1 1], which will lead to uniform
% absorption coefficients for all room boundaries.

load('config.mat');
SetupStruc.Fs = fs;                 % sampling frequency in Hz
SetupStruc.c = room.c;                   % (optional) propagation speed of acoustic waves in m/s
SetupStruc.room = room.dimensions;        % room dimensions in m
SetupStruc.mic_pos = R;
SetupStruc.src_samples = sources.trajectory_samples;
clearvars('current_trajectory');
load('traj.mat');
SetupStruc.src_traj = current_trajectory;                             
SetupStruc.T60 = T60;                 % reverberation time T60, or define a T20 field instead!
% SetupStruc.T20 = 0.15;                % reverberation time T20, or define a T60 field instead!

% SetupStruc.abs_weights = [0.6  0.9  0.5  0.6  1.0  0.8];    % (optional) weights for the resulting alpha coefficients.
% simulates a carpeted floor, and sound-absorbing material on the ceiling and the second x-dimension wall.
