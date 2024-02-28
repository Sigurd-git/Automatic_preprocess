function S = get_stim_information(project_directory,stim_info, subjid)
clear S;
for j = 1:size(stim_info,1)
    X = load([project_directory '/data/subjects-v1/' subjid '/timings-and-behavior-' stim_info{j,1} '.mat']);
    blocks = stim_info{j,2};
    if j == 1
        fldnames = fieldnames(X);
        fldnames_fixed = {'stim_directory', 'stims'};
        fldnames_trial_based = setdiff(fldnames, fldnames_fixed);
        for i = 1:length(fldnames_fixed)
            S.(fldnames_fixed{i}) = X.(fldnames_fixed{i});
        end
    end
    for i = 1:length(fldnames_trial_based)
        S.(fldnames_trial_based{i})(blocks) = X.(fldnames_trial_based{i})(blocks);
    end
end
end