function [sp_path,rp_path] = generate_sourcePath(cfg)

len = cfg.sig_len * cfg.fs;

%% Generate source path
sp_path = zeros(len,3,cfg.n_src);
rp_path = zeros(len,cfg.n_mic,3,cfg.n_pairs);
for idx_src = 1:cfg.n_src
    switch lower(cfg.type_of_movement)
        case 'arc'
            shift_origin = [cfg.synth_room.dim(1:2)/2,cfg.synth_room.height];
            [theta phi r_d] = cart2sph(cfg.synth_room.sloc_start(idx_src,1)-shift_origin(1),cfg.synth_room.sloc_start(idx_src,2)-shift_origin(2),cfg.synth_room.sloc_start(idx_src,3)-shift_origin(3));
            theta = theta*180/pi;
            phi = phi*180/pi;
            
        case 'line'
            start_x = cfg.synth_room.sloc_start(idx_src,1);
            start_y = cfg.synth_room.sloc_start(idx_src,2);
            start_z = cfg.synth_room.sloc_start(idx_src,3);
            
        case 'single_line'
            start_x = cfg.synth_room.sloc_start(idx_src,1);
            start_y = cfg.synth_room.sloc_start(idx_src,2);
            start_z = cfg.synth_room.sloc_start(idx_src,3);
    end
    
    for ii = 1:cfg.hop:len
        switch lower(cfg.type_of_movement)
            % Calculate new source position (arc movement)
            case 'arc'
                [x_tmp, y_tmp, z_tmp] = sph2cart((theta+(ii*cfg.mov_angle)/len)*pi/180,phi*pi/180,r_d);
                sp = shift_origin + [x_tmp y_tmp z_tmp];
                
                % Calculate new source position (line movement)
            case 'line'
                x_tmp = start_x + (ii*(cfg.stop_x(idx_src)-start_x)/len);
                y_tmp = start_y + (ii*(cfg.stop_y(idx_src)-start_y)/len);
                z_tmp = start_z;
                sp = [x_tmp y_tmp z_tmp];
                
            case 'single_line'
                x_tmp = start_x + (ii*(cfg.stop_x(idx_src)-start_x)/len);
                y_tmp = start_y + (ii*(cfg.stop_y(idx_src)-start_y)/len);
                z_tmp = start_z;
                sp = [x_tmp y_tmp z_tmp];
        end
        
        % Store source path
        sp_path(ii:1:min(ii+cfg.hop-1,len),1,idx_src) = sp(1);
        sp_path(ii:1:min(ii+cfg.hop-1,len),2,idx_src) = sp(2);
        sp_path(ii:1:min(ii+cfg.hop-1,len),3,idx_src) = sp(3);
        
        
        % Stationary receiver positions
        for idx_pair=1:cfg.n_pairs
            for mic_idx = 1:cfg.n_mic
                rp_path(ii:1:min(ii+cfg.hop-1,len),mic_idx,1,idx_pair) = cfg.synth_room.mloc(mic_idx,1,idx_pair);
                rp_path(ii:1:min(ii+cfg.hop-1,len),mic_idx,2,idx_pair) = cfg.synth_room.mloc(mic_idx,2,idx_pair);
                rp_path(ii:1:min(ii+cfg.hop-1,len),mic_idx,3,idx_pair) = cfg.synth_room.mloc(mic_idx,3,idx_pair);
            end
        end
    end
end
end