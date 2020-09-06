function ffxDir = getFFXdir(subID, funcFWFM, opt, isMVPA)

    mvpaSuffix = setMvpaSuffix(isMVPA);

    ffxDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', ...
        ['sub-', subID], ...
        'stats', ...
        ['ffx_', opt.taskName], ...
        ['ffx_', mvpaSuffix, num2str(funcFWFM)']);

    if ~exist(ffxDir, 'dir')
        mkdir(ffxDir);
    end
end
