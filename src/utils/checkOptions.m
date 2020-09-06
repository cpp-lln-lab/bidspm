function opt = checkOptions(opt)
    % we check the option inputs and add any missing field with some defaults

    options = getDefaultOption();

    % update options with user input
    % --------------------------------
    I = intersect(fieldnames(options), fieldnames(opt));

    for f = 1:length(I)
        options.(I{f}) = opt.(I{f});
    end

    if ~all(cellfun(@ischar, options.groups))
        disp(options.groups);
        error('All group names should be string.');
    end

    if ~isempty (options.STC_referenceSlice) && length(options.STC_referenceSlice) > 1
        error('options.STC_referenceSlice should be a scalar. Current value is: %d', ...
            options.STC_referenceSlice);
    end

    if ~isempty (options.funcVoxelDims) && length(options.funcVoxelDims) ~= 3
        error('opt.funcVoxelDims should be a vector of length 3. Current value is: %d', ...
            opt.funcVoxelDims);
    end

    opt = options;

end

function options = getDefaultOption()
    % this defines the missing fields

    % group of subjects to analyze
    options.groups = {''};
    % suject to run in each group
    options.subjects = {[]};
    options.zeropad = 2;

    % task to analyze
    options.taskName = '';

    % space where we conduct the analysis
    options.space = '';

    % The directory where the derivatives are located
    options.dataDir = '';

    % Options for slice time correction
    options.STC_referenceSlice = []; % reference slice: middle acquired slice
    options.sliceOrder = []; % To be used if SPM can't extract slice info

    % Options for normalize
    % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
    options.funcVoxelDims = [];

    % Suffix output directory for the saved jobs
    options.jobsDir = '';

    % specify the model file that contains the contrasts to compute
    options.contrastList = {};
    options.model.file = '';

    % specify the results to compute
    options.result.Steps = [];
end
