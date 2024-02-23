function get_parafile(project_directory,S, subjid,trig_onsets_smps,sr,r)

%% Get stimulus by combining group onsets from triggers and stimulus info

% Compute onset of each stimulus
% using the trigger onsets detected above
% and the group-relative onsets.
n_blocks = length(S.groups);
stim_onsets_smps = get_stim_onset(S,trig_onsets_smps,sr);

%% Write timings as a para file

save_para(project_directory,subjid, n_blocks, stim_onsets_smps, S,sr,r);
end