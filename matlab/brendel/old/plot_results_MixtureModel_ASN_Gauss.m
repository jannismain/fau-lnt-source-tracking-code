function [loc_est1, loc_est2] = plot_results_MixtureModel_ASN_Gauss(cfg,psi,psi_plot)

thres_max = 0.5;
disp('compute localization error 1')
psi_complete = psi;

[~,idx_maxX1] = max(max(psi,[],1));
[~,idx_maxY1] = max(max(psi,[],2));
loc_est1 = [cfg.mesh_x(idx_maxX1),cfg.mesh_y(idx_maxY1)];
loc_est1 = loc_est1 + cfg.N_margin*cfg.mesh_res;

disp('compute localization error 2')
psi(idx_maxY1,idx_maxX1) = 0;
[~,idx_maxX2] = max(max(psi,[],1));
[~,idx_maxY2] = max(max(psi,[],2));
loc_est2 = [cfg.mesh_x(idx_maxX2),cfg.mesh_y(idx_maxY2)]+ cfg.N_margin*cfg.mesh_res;
while(norm(loc_est1-loc_est2) < thres_max)  % too many peaks around maximum... threshold for distance between sources
    psi(idx_maxY2,idx_maxX2) = 0;
    [~,idx_maxX2] = max(max(psi,[],1));
    [~,idx_maxY2] = max(max(psi,[],2));
    loc_est2 = [cfg.mesh_x(idx_maxX2),cfg.mesh_y(idx_maxY2)]+ cfg.N_margin*cfg.mesh_res;
end

diff1 = norm(cfg.synth_room.sloc(1,1:2)-loc_est1);
diff2 = norm(cfg.synth_room.sloc(2,1:2)-loc_est1);
[est_error1,idx_est_error_1] = min([diff1,diff2]);
est_error2 = norm(cfg.synth_room.sloc(3-idx_est_error_1,1:2)-loc_est2);
% 3-idx_est_... takes the other estimate not used prior
fprintf('Estimation errors: %1.2f m   %1.2f m\n', est_error1,est_error2);

figure(2)
clf
imagesc(cfg.mesh_x,cfg.mesh_y,psi_plot)
set(gca,'Ydir','Normal')
hold on
for idx_pair = 1:cfg.n_pairs
    plot(cfg.synth_room.mloc(:, 1,idx_pair), cfg.synth_room.mloc(:, 2,idx_pair), 'x','MarkerSize', 12, 'Linewidth',2,'Color','g');
    hold on;
end
plot(cfg.synth_room.sloc(:, 1), cfg.synth_room.sloc(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
plot(loc_est1(1), loc_est1(2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
plot(loc_est2(1), loc_est2(2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
axis([0,cfg.synth_room.dim(1),0,cfg.synth_room.dim(2)])
colorbar
title(sprintf('GMM - Est. Err.: %1.2f m  %1.2f m  T60 = %1.2f sec', est_error1,est_error2,cfg.synth_room.t60));
xlabel('x-Axis \rightarrow')
ylabel('y-Axis \rightarrow')

figure(3)
surf(cfg.mesh_x,cfg.mesh_y,psi_plot)
hold on
stem3(loc_est1(1), loc_est1(2),1.2*psi_complete(idx_maxY1,idx_maxX1),'r')
stem3(loc_est2(1), loc_est2(2),1.2*psi_complete(idx_maxY1,idx_maxX1),'r')
stem3(cfg.synth_room.sloc(1, 1), cfg.synth_room.sloc(1,2),1.2*psi_complete(idx_maxY1,idx_maxX1),'g');
stem3(cfg.synth_room.sloc(2, 1), cfg.synth_room.sloc(2,2),1.2*psi_complete(idx_maxY1,idx_maxX1),'g');

end