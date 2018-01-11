fn_cfg = config_update(2, false, 5, 12, false, 0.3, 5, -1, 3, 0, 1, false);
load(fn_cfg);
x = simulate(fn_cfg, ROOM, R, sources);
[~, phi] = stft(fn_cfg, x);

% EM Algorithm
freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
phi_mat = reshape(phi,em.K,em.T,1,1,room.R_pairs);
phi_mat = repmat(phi_mat,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1);

norm_differences = zeros(em.Y-2*room.N_margin,em.X-2*room.N_margin,room.R_pairs);
for idx_pairs = 1:room.R_pairs
    for idx_x = (room.N_margin+1):(em.X-room.N_margin)
        for idx_y = (room.N_margin+1):(em.Y-room.N_margin)
            norm_differences(idx_y-room.N_margin,idx_x-room.N_margin,idx_pairs) = norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2,1:2),2) - norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2-1,1:2),2);
        end
    end
end

norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));

figure('Position', [20 20 900 450]); hold on;
plt_prp = subplot(121); hold on;
%% phi_tilde_mat
phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K.X.Y.M
phitm = squeeze(phi_tilde_mat(:,1,:,:,1));
phitm25 = squeeze(phitm(25,:,:));
plot(real(phitm25), imag(phitm25), 'r.', 'MarkerSize', 12);
xlabel('Re'); xlim([-2 2]); ylabel('Im'); ylim([-2 2]);

%% prepare reference room plot
plt_room = subplot(122); hold on;
% plot grid across whole room
step = room.grid_resolution;
[Xall,Yall] = meshgrid(step:step:room.dimensions(1)-step,step:step:room.dimensions(2)-step);
Zall = ones(length(Xall), length(Yall));
axd1 = plot3(Xall,Yall,Zall, 'k.', 'MarkerSize', 1);

% % plot grid of possible source locations
% xyMin = sources.wall_distance/10;
% xMax = room.dimensions(1)-sources.wall_distance/10;
% yMax = room.dimensions(2)-sources.wall_distance/10;
% [X,Y] = meshgrid(xyMin:step:xMax,xyMin:step:yMax);
% Z = ones(length(X), length(Y));
% axd2 = plot3(X,Y,Z, 'w.', 'MarkerSize', 1);
grid off;
ax_bg = surf(linspace(0,ROOM(1),ROOM(1)),linspace(0,ROOM(2), ROOM(2)), zeros(ROOM(1), ROOM(2)));
% ax_r = plot(R(:, 1), R(:, 2),'O','MarkerSize', 8, 'Linewidth',1,'Color','g');   
ax_s = plot(S(:, 1), S(:, 2),'x','MarkerSize', 12, 'Linewidth',1,'Color','r');
set(ax_s, 'ZData', 2*ones(size(S, 1),1));
shading interp;
axis([-ROOM_BORDER,ROOM(1)+ROOM_BORDER,-ROOM_BORDER,ROOM(2)+ROOM_BORDER]);

map  = colormap('prism');
map = map(1:size(R, 1)/2, :); % get distinct colors for receivers
colormap([61/255 38/255 168/255]);
time=0.005; last=0; this = 0; i=0;

%% phi differences
% phi_diff = bsxfun(@minus,phi_mat,phi_tilde_mat); % K.T.X.Y.M
% phid6035 = squeeze(phi_diff(24,35,:,:,:));
% for r=1:size(phid6035, 3)
%     c = map(r, :);
%     if r>1, plt_r.MarkerSize = 6; end % decrease size of old receiver pair
%     plt_r = plot(R(r*2-1:r*2, 1), R(r*2-1:r*2, 2),'O','MarkerSize', 12, 'Linewidth',2,'Color',c); 
%     for x=1:20:size(phid6035, 1)
%         for y=1:20:size(phid6035, 2)
%             if mod(r,2)==0, activity_marker = 'y*'; else, activity_marker = 'c*'; end
%             plot(plt_room, (9+x)/10,(9+y)/10, activity_marker, 'MarkerSize', 2);
%             if i>1, this.MarkerSize = 4; end % decrease size of old marker
%             this = plot(plt_prp, real(phid6035(x,y)), imag(phid6035(x,y)), '*', 'Color', c, 'MarkerSize', 12);
%             i = i+1; pause(time);
%         end
%     end
% end
%% angular distances
ang_dist = bsxfun(@power,abs((phi_diff)),2);
angd6035 = squeeze(ang_dist(24,35,:,:,1));

psi = ones(em.Y-2*room.N_margin,em.X-2*room.N_margin,1) * (1 /(em.X-2*room.N_margin)*(em.Y-2*room.N_margin));
psi_old = zeros(size(psi));
variance = em.var;
plt_em = figure('Position', ([20 500 900 450]));
pause(0.01);
for iter = 1:em.iterations
    psi_old = psi;
    
    %% Expectation
    
    pdf = bsxfun(@times,reshape(psi,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
    pdf6025 = squeeze(pdf(24,35,:,:)); surf(subplot(131), pdf6025);
    
    
    mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),em.K,em.T,1,1)); mu(isnan(mu)) = 0;
    mu6025 = squeeze(mu(24,35,:,:)); surf(subplot(132), mu6025);
    
    %% Maximization
    psi = squeeze(sum(sum(mu,2),1)/(em.T*em.K)); psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
    surf(subplot(133), psi)
    variance = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1))./room.R_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
    pause(0.01);
end