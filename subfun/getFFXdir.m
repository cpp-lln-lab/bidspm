function ffxDir = getFFXdir(subNumber, degreeOfSmoothing, opt, isMVPA)

    if isMVPA
        mvpaSuffix = 'MVPA_';
    else
        mvpaSuffix = '';
    end

    ffxDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', ...
        ['sub-', subNumber], ...
        'stats', ...
        ['ffx_', opt.taskName], ...
        ['ffx_', mvpaSuffix, num2str(degreeOfSmoothing)']);

    if ~exist(ffxDir, 'dir')
        mkdir(ffxDir);
    end
end
