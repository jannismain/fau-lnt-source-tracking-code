cfg.freq_range = 40:65;
cfg = set_params_ASN_GMM_tracking(cfg);
% simulate moving sources
[cfg.src_path,cfg.mic_path] = generate_sourcePath(cfg);
