function preprocess_one_sess(exp, subjid, sess, trigchan_name, audiochan_name, project_directory, r, overwrite, tol, stim_info, diff_tolerance, resp_win, fixed_duration, remove1backs)
    chnames = edf2chnames(exp, subjid, sess)
    trigchan = find(strcmp(chnames, trigchan_name));
    audiochan = find(strcmp(chnames, audiochan_name));
    show_channels_from_edf(exp, subjid, sess, {trigchan_name,audiochan_name});
    
    %% specify the start and end and also time window to exclude according to figure, Save all signals from the electrodes, as well as which channels are triggers and which channels are audio.
    analysis_directory = [project_directory '/analysis/preprocessing/' subjid '/r' num2str(r)];
    if ~exist(analysis_directory, 'dir')
        mkdir(analysis_directory);
    end
    second_input_parameter_path = [analysis_directory '/ecogchan_startend_excludewin.mat'];
    if or(~exist(second_input_parameter_path, 'file'),overwrite)
        % ecog channels, found according to name
        disp('Please enter ecog channels (e.g., [1:52 56:79 81:116]):');
        ecogchan = input('');
        % first sample to last sample to analyze
        disp('Please enter start and end sample numbers (e.g., [2012560, 6515540]):');
        startend = input('');
        % first sample and last sample of time window to exclude
        disp('Please enter exclude window if any (e.g., []):');
        excludewin = input('');
        save(second_input_parameter_path,"ecogchan","startend","excludewin")
    else
        load(second_input_parameter_path,"ecogchan","startend","excludewin")
    end
    MAT_file = save_ECoG_from_EDF_as_MAT(exp, subjid, sess, r, ...
            'plot', true, 'startend', startend, 'overwrite', true, ...
                'ecogchan', ecogchan, 'trigchan', trigchan, 'audiochan', audiochan, ...
                    'excludewin', excludewin);
    %% detect_trigger and select the trigger which actually correspond to a group
    
    [trig_onsets_smps,sr] = detect_trigger(project_directory, subjid, r,overwrite,tol);
    
    %% Get the trigger onset of each group according to timing files.
    [trig_onsets_smps,stim_names] = get_timing_and_stimnames(project_directory,trig_onsets_smps,sr,stim_info,exp,subjid,diff_tolerance,r);

    keyboard;
    
    save(stim_name_path, 'stim_names')
    
    %% get stim names, S and para file
    S = get_stim_information(project_directory,stim_info, subjid,exp);
    get_parafile(project_directory,S, subjid,trig_onsets_smps,sr,r);
    
    %% preprocess
    preprocess(subjid, exp, r,resp_win,fixed_duration,overwrite,remove1backs);
end