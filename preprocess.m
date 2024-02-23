function preprocess(subjid, exp, r,resp_win,fixed_duration,overwrite,remove1backs)
fprintf('Preprocessing %s\n', subjid); drawnow;


% get runs from this subject using para
runs = read_runs(exp, subjid);
set(0, 'DefaultFigureRenderer', 'painters');
% for i = 1:length(runs)
    
% r = runs(i);
fprintf('Preprocessing run %d\n', r); drawnow;

% preprocess the raw ecog signal
[MAT_file_preproc_signal, param_idstring] = ...
    raw_ecog_preprocessing_wrapper(exp, subjid, r, ...
    'notchfreqs', [60, 90, 120, 180], 'frac', 0.2, 'overwrite', overwrite);


% measure bandpass envelopes
[MAT_file_envelopes, param_idstring] = ...
    bandpass_envelopes_wrapper(exp, subjid, r, param_idstring, 'overwrite', overwrite);


% detect outliers
[MAT_file_env_withoutliers, param_idstring] = ...
    envelope_outliers_wrapper(exp, subjid, r, param_idstring, 'overwrite', overwrite);
close all;


stimfile = 'stim_names';

%% 

[MAT_file_stim_mapped_envelopes, param_idstring] = ...
    map_envelopes_to_stimuli(exp, subjid, r, param_idstring, ...
    resp_win, fixed_duration, 'overwrite', overwrite, ...
    'stimfile', stimfile, 'remove1backs', remove1backs);
end