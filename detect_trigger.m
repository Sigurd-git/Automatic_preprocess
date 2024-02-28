function [trig_onsets_smps,sr] = detect_trigger(project_directory, subjid, r,overwrite,tol)

trig_onsets_smps_file = [project_directory '/analysis/preprocessing/' subjid '/r' num2str(r) '_trig_onsets_smps.mat'];
if or(~exist(trig_onsets_smps_file, 'file'),overwrite)
    trig_file = [project_directory '/data/ECoG-trigger/' subjid '/r' num2str(r) '.mat'];
    load(trig_file, 'trigger_signal', 'sr', 'excludewin')
    
    % load the trigger template and resample to data rate if needed
    template_file = [project_directory '/data/trigger_template.mat'];
    if ~exist(template_file, 'file')
            copyfile('/scratch/snormanh_lab/shared/code/lab-intracranial-code/trigger_template.mat', template_file);
    end
    X = load(template_file);
    if sr~=X.fs
            trig_template = resample(X.trigform, sr, X.fs);
    else
            trig_template = X.trigform;
    end
    
    % set excluded periods to zero
    if exist('excludewin', 'var')
        for i = 1:size(excludewin)
                trigger_signal(excludewin(i,1):excludewin(i,2)) = 0;
        end
    end
    %%
    % detect triggers in samples
    
    trigger_fig_directory = [project_directory '/figures/trigger-sync/' subjid '/r' num2str(r)];
    trig_onsets_smps = detect_trigger_onsets_without_exportfig(trigger_signal, trig_template, sr,  ...
            'tol', tol,'plot', true, 'figdir', trigger_fig_directory);
    save(trig_onsets_smps_file,"trig_onsets_smps","sr")
else
    load(trig_onsets_smps_file,'trig_onsets_smps','sr')
end