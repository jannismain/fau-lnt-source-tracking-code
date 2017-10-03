function plot_ASR_setup(cfg,r,doa_est)

s = cfg.source_pos_cart;
L = cfg.room_dim;

flag_plot3D = 0;

ref_pos1 = (r(1,:)+r(2,:))/2;
ref_pos2 = (r(3,:)+r(4,:))/2;

% end_line_truth1 = ref_pos1 + 3*(s - ref_pos1);
% end_line_truth2 = ref_pos2 + 3*(s - ref_pos2);

source_dir = zeros(2,cfg.nsrc,cfg.nmic);
for source_idx = 1:cfg.nsrc
    
    source_dir(1,source_idx,1) = cos((90-doa_est(1,source_idx))/180 *pi);
    source_dir(2,source_idx,1) = sin((90-doa_est(1,source_idx))/180 *pi);
    source_dir(1,source_idx,2) = cos((180-doa_est(2,source_idx))/180 *pi);
    source_dir(2,source_idx,2) = sin((180-doa_est(2,source_idx))/180 *pi);
    
end

end_line_est1 = repmat(ref_pos1,cfg.nsrc,1) + 100*[source_dir(:,:,1).',zeros(cfg.nsrc,1)];
start_line_est1 = ref_pos1;

end_line_est2 = repmat(ref_pos2,cfg.nsrc,1) + 100*[source_dir(:,:,2).',zeros(cfg.nsrc,1)];
start_line_est2 = ref_pos2;

figure(10);

if(flag_plot3D)
    plot3(r(:,1),r(:,2),r(:,3),'x');
    hold on;
    plot3(s(:,1),s(:,2),s(:,3),'x');
    hold on;
    % plot3([ref_pos(1), end_line_truth1(1)],[ref_pos(2), end_line_truth1(2)],[ref_pos(3), end_line_truth1(3)]);
    % hold on
    plot3([start_line_est1(1), end_line_est1(1)],[start_line_est1(2), end_line_est1(2)],[start_line_est1(3), end_line_est1(3)]);
    hold on
    plot3([start_line_est2(1), end_line_est2(1)],[start_line_est2(2), end_line_est2(2)],[start_line_est2(3), end_line_est2(3)]);
    hold on
    
    axis([0 L(1) 0 L(2) 0 L(3)]);
    grid on;
    box on;
    axis square;
    hold off;
    xlabel('x axis \rightarrow')
    ylabel('y axis \rightarrow')
    zlabel('z axis \rightarrow')
    
else
    plot(r(:,1),r(:,2),'x','MarkerSize', 12);
    hold on;
    plot(s(:,1),s(:,2),'x','MarkerSize', 12);
    hold on;
    for source_idx = 1:cfg.nsrc
        plot([start_line_est1(1), end_line_est1(source_idx,1)],[start_line_est1(2), end_line_est1(source_idx,2)]);
        hold on
        plot([start_line_est2(1), end_line_est2(source_idx,1)],[start_line_est2(2), end_line_est2(source_idx,2)]);
        hold on
    end
    
    axis([0 L(1) 0 L(2)]);
    grid on;
    box on;
%     axis square;
    hold off;
    xlabel('x axis \rightarrow')
    ylabel('y axis \rightarrow')
end

end