function [new_counter] = next_step(description, counter, STEP, STOP_AFTER_STEP)

    fprintf('  [%d] %s\n', counter, description);
    new_counter = counter+1;

end
