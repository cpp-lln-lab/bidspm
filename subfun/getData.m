function [group, opt, BIDS] = getData(opt)
% The following structure will be the base that the function will use to run
% the preprocessing pipeline according to the BIDS Structure

opt = checkOptions(opt);

fprintf(1,'FOR TASK: %s\n', opt.taskName)

% The directory where the derivatives are located
derivativesDir = opt.derivativesDir;

% we let SPM figure out what is in this BIDS data set
BIDS = spm_BIDS(derivativesDir);

% get IDs of all subjects
subjects = spm_BIDS(BIDS, 'subjects');

% get metadata for bold runs for that task
% we take those from the first run of the first subject assuming it can
% apply to all others.
metadata = spm_BIDS(BIDS, 'metadata', ...
    'task', opt.taskName, ...
    'sub', subjects{1}, ...
    'type', 'bold');
if iscell(metadata)
    opt.metadata = metadata{1};
else
    opt.metadata = metadata;
end

%% Add the different groups in the experiment
for iGroup = 1:numel(opt.groups) % for each group
    
     % Name of the group
    group(iGroup).name = opt.groups{iGroup}; %#ok<*AGROW>                           

    % we figure out which subjects to take if not specified take all subjects
    if isfield(opt,'subjects') && ~isempty(opt.subjects{iGroup})
        
        idx = opt.subjects{iGroup};
        
        % Number of subjects in the group
        group(iGroup).numSub = length(idx) ; 
        
        % find the subjects that belong to that group
        groupSubIdx = ~cellfun('isempty', strfind(subjects,group(iGroup).name)); % compare the subjects with the group name 
        groupSubs = subjects(groupSubIdx) ;                                  % Get the index of the subjects corresponding to this group
        group(iGroup).subNumber = groupSubs(idx);                            % SUBJECT ID .. con01 , con02 , etc.
        
    else
        
        % in case no group was specified (e.g. sub-01) we need a way to still
        % get the subjects ID
        if strcmp(group(iGroup).name, '')
            idx = 1:size(subjects,2);
        else
            idx = strfind(subjects, group(iGroup).name);
            idx = find(~cellfun('isempty', idx));
        end      
        group(iGroup).subNumber = subjects(idx);                            % SUBJECT ID .. con01 , con02 , etc.
        group(iGroup).numSub = length(group(iGroup).subNumber) ;            % Number of subjects in the group
        
    end
    
    
    fprintf(1,'WILL WORK ON SUBJECTS\n')
    disp(group(iGroup).subNumber)
end


end

function opt = checkOptions(opt)
% we check the option inputs and add any missing field with some defaults

options = getDefaultOption();

% update options with user input
% --------------------------------
I = intersect(fieldnames(options), fieldnames(opt));

for f = 1:length(I)
    options = setfield( options,I{f}, getfield(opt,I{f}));
end

if strcmp (options.groups{1}, '') && ~isempty(options.subjects{1})
    warning('you want to analyze all groups but still mentioned a subject index : this is not supported at the moment. We will take all the subjects from all groups.')
    options.subjects = {[]}; 
end

if ~isempty (options.STC_referenceSlice) && length(options.STC_referenceSlice)>1
    error('options.STC_referenceSlice should be a scalar and current value is: %d', options.STC_referenceSlice)
end

if ~isempty (options.funcVoxelDims) && length(options.funcVoxelDims)~=3
    error('opt.funcVoxelDims should be a vector of length 3 and current value is: %d', opt.funcVoxelDims)
end

opt = options;

end


function options = getDefaultOption()
% this defines the missing fields

% group of subjects to analyze
options.groups = {''};
% suject to run in each group
options.subjects = {[]}; 

% task to analyze
options.taskName = '';

% The directory where the derivatives are located
options.derivativesDir = '';

% Specify the number of dummies that you want to be removed.
options.numDummies = 0;
options.dummyPrefix = 'dr_';

% Options for slice time correction
options.STC_referenceSlice = []; % reference slice: middle acquired slice
options.sliceOrder = []; % To be used if SPM can't extract slice info

% Options for normalize
% Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
options.funcVoxelDims = [];

% Suffix output directory for the saved jobs
options.JOBS_dir = '';

% specify the model file that contains the contrasts to compute
options.contrastList = {};
options.model.file = '';
end
