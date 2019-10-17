function ffxDir = getFFXdir(subNumber, degreeOfSmoothing, opt, isMVPA)

if nargin<4
    isMVPA = false;
end

if isMVPA
    mvpaSuffix = 'MVPA_';
else
    mvpaSuffix = '';
end

ffxDir = fullfile(opt.derivativesDir, ...
    ['sub-', subNumber], ...
    'stats', ...
    ['ffx_', opt.taskName],...
    ['ffx_', mvpaSuffix, num2str(degreeOfSmoothing)']);

if ~exist(ffxDir,'dir')
    mkdir(ffxDir)
end
end
