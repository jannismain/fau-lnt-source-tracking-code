
function x = createMicSignals_ASN(cfg)

% load sources
s = zeros(cfg.sig_len*cfg.fs, cfg.nsrc);
for q = 1:cfg.nsrc
    [tmp,f] = audioread(cfg.synth_room.src_paths{q});
    tmp = resample(tmp,cfg.fs,f);
    if cfg.sig_len ~= 0
        while length(tmp)<(cfg.sig_len*cfg.fs)
            tmp = cat(1,tmp,tmp);
        end
%         tmp = rand(size(tmp));
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

h = zeros(cfg.synth_room.Nh,cfg.n_src,cfg.n_mic, cfg.n_pairs);
for idx_pair = 1:cfg.n_pairs
    for p=1:size(cfg.synth_room.sloc, 1)
        h(:, p, :,idx_pair) = rir_generator(cfg.c, cfg.fs, cfg.synth_room.mloc(:,:,idx_pair), cfg.synth_room.sloc(p, :), cfg.synth_room.dim, cfg.synth_room.t60, cfg.synth_room.Nh, 'omnidirectional', cfg.synth_room.order, 3, 0, 1)';
        % TODO vectorize to compute all rirs at once
        % takes long time for higher reflection orders..
    end
end

h = h/(max(max(max(max(h)))));

cfg.synth_room.nsrc = size(s, 2);
xsrc = zeros(size(s,1), cfg.nsrc, cfg.n_mic, cfg.n_pairs); % structure: xsrc(samples, #speaker, #mics, #pairs)
for idx_pair = 1:cfg.n_pairs
    for q = 1:cfg.nsrc
        for p = 1:cfg.n_mic
            xsrc(:, q, p,idx_pair) = fftfilt(squeeze(h(:, q, p,idx_pair)),s(:, q));
        end
    end
end

%--------------------------------------------------------------
% Sum up the individual source components to obtain the mic
% signals
%--------------------------------------------------------------
x = squeeze(sum(xsrc,2));

end



