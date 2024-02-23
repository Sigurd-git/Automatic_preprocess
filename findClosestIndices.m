function [closestIndices, differences] = findClosestIndices(gt, trig_onsets_smps_in_s)
    % Initialize vectors to store the indices of the closest elements and their differences
    closestIndices = zeros(length(gt), 1);
    differences = zeros(length(gt), 1);
    
    % Loop through each element in gt
    for i = 1:length(gt)
        % Calculate the absolute differences between the current gt element and all elements in trig_onsets_smps_in_s
        diffs = abs(trig_onsets_smps_in_s - gt(i));
        
        % Find the index of the smallest difference, which indicates the closest element
        [minDiff, idx] = min(diffs);
        
        % Store the index of the closest element and the corresponding difference
        closestIndices(i) = idx;
        differences(i) = minDiff;
    end
end
