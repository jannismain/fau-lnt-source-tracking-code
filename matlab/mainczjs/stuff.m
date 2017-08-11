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