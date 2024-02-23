function save_para(project_directory,subjid, n_blocks, stim_onsets_smps, S,sr,r)
para_file = [project_directory '/data/para/' subjid '/r' num2str(r) '.par'];
fid = fopen(mkpdir(para_file), 'w');
for i = 1:n_blocks
    n_stims_per_block = length(stim_onsets_smps{i});
    si = S.stim_order{i};
    for j = 1:n_stims_per_block
        stim_name = S.stims{si(j)};
        wavinfo = audioinfo([project_directory '/stimuli/' stim_name '.wav']);
        dur = wavinfo.Duration;
        
        fprintf(fid,'%10.6f%5d%10.6f%5d%90s\n', ...
            stim_onsets_smps{i}(j)/sr, NaN, dur, NaN, stim_name);
    end
end
fclose(fid);
end