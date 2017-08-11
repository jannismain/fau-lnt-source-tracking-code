function [new_counter] = next_step(description, counter, STEP, STOP_AFTER_STEP)

if STOP_AFTER_STEP > 0
    if counter > STOP_AFTER_STEP
        error('Execution stopped');
    end
end

if STEP == 1
    if counter > 1
        fprintf('...Press button to continue!\n'); 
        pause; 
    end
end

fprintf('  [%d] %s\n', counter, description);
new_counter = counter+1;

end
