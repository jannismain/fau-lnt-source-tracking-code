
function x = createMicSignals_ASN_vonMises_tracking(cfg)

% load sources
s = zeros(cfg.sig_len*cfg.fs, cfg.nsrc);
for q = 1:cfg.nsrc
    [tmp,f] = audioread(cfg.synth_room.src_paths{q});
    tmp = resample(tmp,cfg.fs,f);
    if cfg.sig_len ~= 0
        while length(tmp)<(cfg.sig_len*cfg.fs)
            tmp = cat(1,tmp,tmp);
        end
        s(1:cfg.sig_len*cfg.fs,q) = tmp(1:cfg.sig_len*cfg.fs);
    else
        if (1==q)
            s = zeros(length(tmp), cfg.synth_room.nsrc);
        end
        s(:, q) = tmp;
    end
end
%--------------------------------------------------------------
% Illustartion of simulated environment and the corresponding
% synthetic IRs
%--------------------------------------------------------------

cfg.synth_room.nsrc = size(s, 2);
xsrc = zeros(size(s,1), cfg.nsrc, cfg.n_mic, cfg.n_pairs); % structure: xsrc(samples, #speaker, #mics, #pairs)
for idx_pair = 1:cfg.n_pairs
    for q = 1:cfg.nsrc
        for p = 1:cfg.n_mic
            [xsrc(:, q, p,idx_pair),beta_hat] = signal_generator(s(:, q).',cfg.c,cfg.fs,squeeze(cfg.mic_path(:,p,:,idx_pair)),cfg.src_path(:,:,q),cfg.synth_room.dim,cfg.synth_room.t60,cfg.synth_room.Nh,'o',cfg.synth_room.order);
        end
    end
end

%--------------------------------------------------------------
% Sum up the individual source components to obtain the mic
% signals
%--------------------------------------------------------------
x = squeeze(sum(xsrc,2));

end


