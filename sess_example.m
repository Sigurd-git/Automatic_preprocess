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
subjid = 'UR14' ;
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
stim_info = {'23-06-06_11-01-24-173', 1:8}; %{date1,blk_numbers1; data2,blk_numbers2,...},


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

% show channel names, display and optionally plot the channels from EDF
preprocess_one_sess(exp, subjid, sess, trigchan_name, audiochan_name, project_directory, r, overwrite, tol, stim_info, diff_tolerance, resp_win, fixed_duration, remove1backs);