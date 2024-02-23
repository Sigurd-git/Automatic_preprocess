function [trig_onsets_smps,stim_names] = get_timing_and_stimnames(project_directory,trig_onsets_smps,sr,stim_info,project,subjid,tolerance,r)
% Function to read 'blk' and 'time' columns from a given text file.
    %
    % Args:
    %   filename (string): Path to the timing text file.
    %   triger_onsets_in_second
    %   stim_info
    %   project
    %   subjid
    %
    % Returns:
    %   blk (array): Array containing values from the 'blk' column.
    %   time (array): Array containing values from the 'time' column.
    n_second_per_trigger = 20;
    triger_onsets_in_second = trig_onsets_smps/sr;
    gts = cell(size(stim_info,1),1);
    stim_names = {};
    stim_count = 1;
    for j = 1:size(stim_info,1)
        filename = [project_directory '/data/subjects-v1/' subjid '/' project '/timing-' stim_info{j,1} '.txt'];

        % Generate import options for the text file
        opts = detectImportOptions(filename, 'FileType', 'text');
        % Select only 'blk' and 'time' columns to be read
        opts.SelectedVariableNames = {'blk','grp','ind', 'time', 'name'};

        % Read the specified columns from the file
        data = readtable(filename, opts);
        % Get unique blk values
        uniqueBlks = stim_info{j,2};
        n=length(uniqueBlks);
        gt = zeros(n,1);


        % Loop through each unique blk value
        for i = 1:n
            % Filter rows where blk is the current unique value
            blkRows = data(data.blk == uniqueBlks(i), :);
            stim_names{stim_count} = blkRows.name;
            stim_count = stim_count+1;
            % Filter rows where ind is 1 for each group
            filteredRows = blkRows(blkRows.ind == 1, :);
            % Extract the time values for these rows
            gt(i) = filteredRows.time;
        end

        if j == 1
            triger_onset_in_second = triger_onsets_in_second(1);
            gt = gt-gt(1)+triger_onset_in_second;

            % get triger_onsets_in_second which is larger than gt(end)
            rest_triggers = triger_onsets_in_second(triger_onsets_in_second > gt(end));
        else
            final_stim_name = blkRows.name(end);
            wavinfo = audioinfo([project_directory '/stimuli/' final_stim_name '.wav']);
            dur = wavinfo.Duration;
            
            n_trigger = floor(delta_t/n_second_per_trigger);
            delta_t = gt(end)-gt(1)+dur;
            rest_triggers_diff = diff(rest_triggers);
            diff_in_theory = repmat(n_second_per_trigger,n_trigger,1);
            trigger_index = find_trigger_index(rest_triggers_diff, diff_in_theory, tolerance);
            triger_onset_in_second = rest_triggers(trigger_index);
            gt = gt-gt(1)+triger_onset_in_second;
            rest_triggers = triger_onsets_in_second(triger_onsets_in_second > gt(end));
        end
        gts{j} = gt;

    end
    gt = vertcat(gts{:});
    stim_names = vertcat(stim_names{:});
    stim_names = unique(stim_names);
    
    trigger_MAT_file = [project_directory '/data/ECoG-trigger/' subjid '/r' num2str(r) '.mat'];
    audio_MAT_file = [project_directory '/data/ECoG-audio/' subjid '/r' num2str(r) '.mat'];
    trigger_signal = load(trigger_MAT_file,'trigger_signal').trigger_signal;
    audio_signal = load(audio_MAT_file,'audio_signal').audio_signal;
    
    [indices, diffs] = findClosestIndices(gt, trig_onsets_smps/sr);
    assert(all(diffs < tolerance),...
        ['Not all differences are less than 0.1,' ...
        ' you may want to make sure that' ...
        '  the trigger are well selected.']);
    trig_onsets_smps = trig_onsets_smps(indices);
    
    
    
    % Plots
    close all;
    figure;
    hold on; 
    plot(trigger_signal);
    title('Trigger');
    % Assume trig_onsets_smps is an n x 1 array containing the x-coordinates at which to draw vertical lines.
    for t = 1:length(trig_onsets_smps)
        x = trig_onsets_smps(t); % Get the x-coordinate of the vertical line to be drawn.
        yLimits = ylim; % Get the y-axis range of the current graph so that the vertical line can be drawn from the bottom to the top.
        plot([x, x], yLimits, 'r--'); % Draw a vertical line, using red dashed line here.
    end
    hold off;
    
    figure;
    hold on; 
    plot(audio_signal);
    title('Audio');
    for t = 1:length(trig_onsets_smps)
        x = trig_onsets_smps(t); % Get the x-coordinate of the vertical line to be drawn.
        yLimits = ylim; % Get the y-axis range of the current graph so that the vertical line can be drawn from the bottom to the top.
        plot([x, x], yLimits, 'r--'); % Draw a vertical line, using red dashed line here.
    end
    hold off;
end