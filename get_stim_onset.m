function stim_onsets_smps = get_stim_onset(S,trig_onsets_smps,sr)
n_blocks = length(S.groups);
group_count = 0;
stim_onsets_smps = cell(1, n_blocks);
for i = 1:n_blocks
    n_groups_per_block = sum(~isnan(S.group_onsets{i}));
    n_stims_per_block = sum(~isnan(S.stim_onsets{i}));
    stim_onsets_smps{i} = nan(1, n_stims_per_block);
    for j = 1:n_groups_per_block
        group_count = group_count + 1;

        % indices for this group
        % typically {[1,2,3,4],
        % [5,6,7,8], etc.} assuming
        % groups of size 4
        gi = S.groups{i}{j};

        % onset
        % relative
        % to group
        group_relative_onsets_sec = S.group_relative_onsets{i}{j};
        group_relative_onsets_smp = round(group_relative_onsets_sec*sr);

        % add group relative onset to trigger
        stim_onsets_smps{i}(gi) = trig_onsets_smps(group_count) + group_relative_onsets_smp;
    end
    assert(all(~isnan(stim_onsets_smps{i})));
end
assert(group_count==length(trig_onsets_smps));
end