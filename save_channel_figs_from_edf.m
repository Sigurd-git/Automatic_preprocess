function sig = save_channel_figs_from_edf(exp, subjid, sess, chnames,r,overwrite)

    % Plot specific channels from EDF file. Useful for example for detecting
    % the trigger/audio channels.
    % 
    % 2019-11-11: Commented Sam NH
    
    global root_directory
    
    % directory for this project
    project_directory = [root_directory '/' exp];
    figure_directory = [project_directory '/figures/EDF/' subjid '/r' num2str(r)];
    if ~exist(figure_directory, 'dir')
        mkdir(figure_directory);
    end

    if ~exist([figure_directory '/audio_trigger.fig'], 'file') || overwrite
        % read in specified channels
        edf_file = [project_directory '/data/ECoG-EDF/' subjid '/sess' num2str(sess) '.edf'];
        % [~, sig] = edfread(edf_file, 'targetSignals', chnames);
        [~, sig] = edfreadUntilDone(edf_file, 'targetSignals', chnames);
        
        % plot
        figh = figure;
        for i = 1:length(chnames)
            subplot(length(chnames), 1, i);
            plot(sig(i,:));
            title(chnames{i});
        end
        saveas(figh, [figure_directory '/audio_trigger.fig'])
    
    else
        openfig([figure_directory '/audio_trigger.fig'])
    end