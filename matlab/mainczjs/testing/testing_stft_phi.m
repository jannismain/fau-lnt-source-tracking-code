figure;
hold on;

%% MAIN
% main.x
clear all;
try
    main = load('x.mat');
catch err
    tic;
    config_update;
    load('config.mat');
    main.x = simulate(ROOM, R, S);
    fprintf('main.x done! (t = %s)\n', num2str(toc)');
%     save('x.mat', 'x');
end
subplot(2,2,1);
plot(main.x(:,1,1));

% main.phi
[~, main.phi] = stft(main.x);
subplot(2,2,3);
plot(angle(main.phi(1:5,:,1)'))
save('main.mat', 'main');


%% BREN
% bren.x
clear all;
tic;
cfg = set_params_evaluate_Gauss();
try
    bren = load('x_brendel.mat');
catch err
    bren.x = createMicSignals_ASN_vonMises(cfg);
    fprintf('bren.x done! (t = %s)\n', num2str(toc)');
%     save('x_brendel.mat', 'x');
end
subplot(2,2,2);
plot(bren.x(:,1,1));

% bren.phi
    fprintf('Compute phase differences...\n');
    cfg.T = floor((size(bren.x,1)-cfg.winpts)/cfg.steppts)+1;
    bren.phi = zeros(cfg.K,cfg.T,cfg.n_pairs);
    for idx_pair = 1:cfg.n_pairs
        x1 = bren.x(:,1,idx_pair) + 0.01*(rand(size(bren.x(:,1,idx_pair)))-0.5);
        x2 = bren.x(:,2,idx_pair) + 0.01*(rand(size(bren.x(:,2,idx_pair)))-0.5);
        X1 = specgram(x1,cfg.nfft,cfg.fs,cfg.window,cfg.n_overlap);
        X2 = specgram(x2,cfg.nfft,cfg.fs,cfg.window,cfg.n_overlap);
        bren.phi(:,:,idx_pair) = (X2(cfg.freq_range,:)./X1(cfg.freq_range,:)).*abs(X1(cfg.freq_range,:)./X2(cfg.freq_range,:));
    end
subplot(2,2,4);
plot(angle(bren.phi(1:5,:,1)'))
save('bren.mat', 'bren');

% clear all;
load('bren.mat');
load('main.mat');
diff.phi = main.phi - bren.phi;
figure;
plot(angle(diff.phi(1:5,:,1)'))

    



