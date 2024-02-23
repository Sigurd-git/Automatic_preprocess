function trigger_index = find_trigger_index(rest_triggers_diff, diff_in_theory, tolerance)
    n = length(rest_triggers_diff);
    k = length(diff_in_theory);
    trigger_index = -1; % Initialized as -1, indicating not found.
    
    % Loop through rest_triggers_diff until n-k+1 to ensure there are enough elements to compare with diff_in_theory.
    for i = 1:(n-k+1)
        % Calculate the difference
        diff = abs(rest_triggers_diff(i:i+k-1) - diff_in_theory);
        
        % Check if all differences are less than tolerance.
        if all(diff < tolerance)
            trigger_index = i; % Find the starting index that meets the conditions.
            break; % Exit the loop
        end
    end
end