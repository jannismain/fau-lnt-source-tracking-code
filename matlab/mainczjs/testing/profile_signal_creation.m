%% plot
figure;
hold on;

%% create signal (main)
clear all;
try
    main = load('x.mat');
catch err
    tic;
    config_update(7,true,0,0,true,1.0,5,-1,-1,30,false);
    load('config.mat');
    main.x = simulate(ROOM, R, S);
    fprintf('main done! (t = %s)\n', num2str(toc)');
    subplot(1,2,1);
    plot(main.x(:,1,1));
%     save('x.mat', 'x');
end

%% create signal (bren)
% clear all;
% try
%     bren = load('x_brendel.mat');
% catch err
%     tic;
%     cfg = set_params_evaluate_Gauss();
%     bren.x = createMicSignals_ASN_vonMises(cfg);
%     fprintf('bren done! (t = %s)\n', num2str(toc)');
%     subplot(1,2,2);
%     plot(bren.x(:,1,1));
% %     save('x_brendel.mat', 'x');
% end



