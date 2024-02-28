function trigger_index = find_trigger_index(rest_triggers, n_second_per_trigger,n_trigger, tolerance)
    n = length(rest_triggers);
    trigger_index = -1; % Initialized as -1, indicating not found.
    
    % Loop through rest_triggers until n-k+1 to ensure there are enough elements to compare with diff_in_theory.
    for i = 1:n
        n_all_trigger = n-i+1;
        t0 = rest_triggers(i);
        rest_triggers = reshape(rest_triggers,[1 n]);
        rest_triggers_grid = repmat(rest_triggers, n_trigger,1)';
        % Calculate the difference
        delta = ((1:n_trigger)-1)*n_second_per_trigger;
        t_theory = delta+t0;
        t_theory = reshape(t_theory,[1 n_trigger]);
        t_theory_grid = repmat(t_theory, n_all_trigger,1); %real,theory
        diff = abs(rest_triggers_grid - t_theory_grid)<tolerance;
        % if any of the row is true, then the column is true
        exists = any(diff,1);
        all_exist = all(exists);
        if all_exist
            trigger_index = i;
            break
        end
    end
end