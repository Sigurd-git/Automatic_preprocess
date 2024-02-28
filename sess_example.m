lab_scratch_directory = '/scratch/snormanh_lab';
shared_code_directory = [lab_scratch_directory '/shared/code'];

addpath(genpath([shared_code_directory '/lab-intracranial-code']));
addpath(genpath([shared_code_directory '/lab-analysis-code']));
addpath(genpath([shared_code_directory '/Automatic_preprocess']));
addpath([shared_code_directory '/export_fig']);

% declare the root directory where all of your projects are
% typically your home directory on scratch
% this variable is used by subsequent code
% which is why we are declaring it a global variable
global root_directory;

% customize parameters
% The root directory, customize!!!!!!!!!!!
root_directory = '/scratch/snormanh_lab/shared/temp/sigurd'; 
% The name of this experiment, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
exp = 'speech-long-TCI' ;
% The name of this subject, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subjid = 'UR17' ;
% The number of this session, found in task notes, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sess = 5; 
% The rank of this run, found in task notes, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
r = 1 ;
% The name of trigger channel found in session notes, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
trigchan_name = 'DC1'; % This is usually DC1;
% The name of trigger channel also found in session notes, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
audiochan_name = 'DC2'; % This is usually DC2;

% look at all the timing files, make sure that each blk number appears once, 
% and blk number from later timing file is the right one if there are multiple 
% files containing the same blk number, customize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
stim_info = {'24-01-13_16-18-27-929', 1:8}; %{date1,blk_numbers1; data2,blk_numbers2,...},


% fixed parameters
project_directory = [root_directory '/' exp];
overwrite = false;
stim_name_path = [root_directory '/' exp '/analysis/stim_names.mat'];

% detect trigger parameters, customize only when you can not detect trigger
% well
tol = 0.4;
diff_tolerance=0.1;

% preprocess parameters
remove1backs=false;
resp_win = [-1 1];
fixed_duration = false; 
analysis_directory = [project_directory '/analysis/preprocessing/' subjid '/r' num2str(r)];
if ~exist(analysis_directory, 'dir')
    mkdir(analysis_directory);
end
%% 
session_chnames_path = [analysis_directory '/chnames.mat'];
% show channel names, display and optionally plot the channels from EDF
chnames = edf2chnames(exp, subjid, sess);

trigchan = find(strcmp(chnames, trigchan_name));
audiochan = find(strcmp(chnames, audiochan_name));

%% 
save_channel_figs_from_edf(exp, subjid, sess, {trigchan_name,audiochan_name},r,overwrite);

%% specify the start and end and also time window to exclude according to figure, Save all signals from the electrodes, as well as which channels are triggers and which channels are audio.


second_input_parameter_path = [analysis_directory '/ecogchan_startend_excludewin.mat'];
chnames'
if or(~exist(second_input_parameter_path, 'file'),overwrite)
    % ecog channels, found according to name
    disp('Please enter ecog channels (e.g., [1:52 56:79 81:116]):');
    ecogchan = input('');
    ecogchan'
    % first sample to last sample to analyze
    disp('Please enter start and end sample numbers (e.g., [2012560, 6515540]):');
    startend = input('')
    % first sample and last sample of time window to exclude
    disp('Please enter excluded window (e.g., []):');
    excludewin = input('')
    save(second_input_parameter_path,"ecogchan","startend","excludewin")
else
    load(second_input_parameter_path,"ecogchan","startend","excludewin")
    ecogchan'
    startend
    excludewin
end
MAT_file = save_ECoG_from_EDF_as_MAT(exp, subjid, sess, r, ...
        'plot', true, 'startend', startend, 'overwrite', overwrite, ...
            'ecogchan', ecogchan, 'trigchan', trigchan, 'audiochan', audiochan, ...
                'excludewin', excludewin);
%% detect_trigger and select the trigger which actually correspond to a group

[trig_onsets_smps,sr] = detect_trigger(project_directory, subjid, r,overwrite,tol);

%% Get the trigger onset of each group according to timing files.
[trig_onsets_smps,stim_names] = get_timing_and_stimnames(project_directory,trig_onsets_smps,sr,stim_info,exp,subjid,diff_tolerance,r);
disp('Please check whether the redline in at the onset of each group.');
disp('Press continue or enter dbcont if it is correct.');
keyboard;
save(stim_name_path, 'stim_names')

%% get stim names, S and para file
S = get_stim_information(project_directory,stim_info, subjid);
get_parafile(project_directory,S, subjid,trig_onsets_smps,sr,r);


%% preprocess
fprintf('Preprocessing %s\n', subjid); drawnow;


% get runs from this subject using para
runs = read_runs(exp, subjid);
set(0, 'DefaultFigureRenderer', 'painters');
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

%% 
stimfile = 'stim_names';
[MAT_file_stim_mapped_envelopes, param_idstring] = ...
    map_envelopes_to_stimuli(exp, subjid, r, param_idstring, ...
    resp_win, fixed_duration, 'overwrite', overwrite, ...
    'stimfile', stimfile, 'remove1backs', remove1backs);