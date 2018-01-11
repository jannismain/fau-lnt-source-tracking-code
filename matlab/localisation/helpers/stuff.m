%% stft.m -> Calculation of cross correlation
% m = "Calculate cross-correlation of received signals"; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
%     
%     [c,lag] = xcorr(Y_m(1, :), Y_m(2,:));
%     [~, I] = max(abs(c));
%     lag_delta = lag(I);
%     t_delta = (lag_delta*1000)/fs;
%     sprintf(num2str(t_delta, '%5.5\n'));
%     if PLOT(1) && PLOT(counter)
%         figure; plot(lag,c);
%         title('Cross-Correlation xcorr(r1, r2)');
%     end


%% simulate.m -> plot H
%     if PLOT(1) && PLOT(counter)
%         figure; plot_count = 1;
%         for r = 1:size(H, 1)
%             for s = 1:size(H, 2)
%                 subplot(size(H, 1), size(H, 2), plot_count);
%                 plot(squeeze(H(r,s,:)));
%                 title(strcat("RIR(R_{", int2str(r), "}, S_{", int2str(s), "})"))
%                 plot_count = plot_count + 1;
%             end
%         end
%     end

%% simulate.m -> plot Y
%     if PLOT(1) && PLOT(counter)
%         figure; plot_count = 1;
%         for r = 1:n_receiver_pairs
%             for s = 1:n_sources
%                 subplot(size(Y, 1), size(Y, 2), plot_count);
%                 plot(squeeze(Y(r,s,:)));
%                 title(strcat("S_{", int2str(s), "} x RIR(R_{", int2str(r), "}, S_{", int2str(s), "})"))
%                 plot_count = plot_count + 1;
%             end
%         end
%     end

%% simulate.m -> plot x
%     if PLOT(1) && PLOT(counter)
%         figure;
%         for r = 1:n_receivers
%             subplot(n_receivers, 1,r);
%             plot(x(1,:));
%             title(strcat("R_{", int2str(r), "}"))
%         end
%     end
%     
%     if PLAY_AUDIO > 0 && PLAY_AUDIO <= n_receivers
%         sound(x(PLAY_AUDIO, :), fs);
%     end

%% simulate.m -> doa_trig_calc
% DoA Calculation...
% m = "Actual DoA Calculation..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
%     DOA = doa_trig(S,R);
%     for s=1:n_sources
%         fprintf('%s Actual DOA(S_{%d}): %0.2f\x03C0 (%0.1f\x00B0)\n', FORMAT_PREFIX, s, deg2rad(DOA(s)/pi), DOA(s));
%     end

%% simulate.m -> mixing signals alternative
%     x = zeros(n_samples_y, 2, n_receiver_pairs);
%     for mic_pair = 1:n_receiver_pairs
%         for mic = 1:2
%             for s = 1:n_sources
%                 x(:, mic, mic_pair) = x(:, mic, mic_pair) + squeeze(squeeze(Y(:, s, mic, mic_pair)));
%             end
% %             fprintf("%s R%d.%d (length = %d)\n", FORMAT_PREFIX, mic_pair, mic, length(x(:, mic, mic_pair))); 
%         end
%     end

%% simulate.m -> trim all source signals to length of shortest one
% inside for loop:
%         if (n_samples_s == 0) || ( n_samples_s > length(temp))
%             fprintf("%s New minimal sample length: %6.0d (was %d)\n", FORMAT_PREFIX, length(temp), n_samples_s); 
%             n_samples_s = length(temp);
%         end

% outside for loop:
%     n_samples_s = source_length*fs;  % trim signals to 3 seconds instead of the shortest signal length
%     S_data = S_data(1:n_samples_s, :);
%     fprintf("%s Truncated S to %dx%d\n", FORMAT_PREFIX, size(S_data, 1), size(S_data, 2));

%% testbed_dynamic.m -> visualize random sample of audio signals
% fig_size = [1800 1400];  % width x height
% scr_size = get(0,'ScreenSize');
% fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
% fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
% 
% f = figure('Name','Sample of Simulated RIRs',...
%                   'NumberTitle','off',...
%                   'Color','white',...
%                   'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)],...
%                   'MenuBar','none');
% for n = 1:9
%     ax = subplot_tight(3,3,n, .05);
%     m = randi(24,1);
%     t = randi(201,1);
% %     rir = cell2mat(temp.RIR_cell(m,t));
% %     source = conv(source,rir);
%     plot(source_data(:,1))
% %     ylim([-0.1 0.1])
%     title('Signal at mic #1');
% end