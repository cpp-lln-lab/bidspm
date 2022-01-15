function [roiList, roiFolder] = getROIs(varargin)
  %
  % get the rois from :
  %
  % - the group folder when running analysis in MNI space
  % - the sub-*/roi/ folder when in individual space
  %
  % USAGE::
  %
  % [roiList, roiFolder] = getROIs(opt, subLabel)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  p = inputParser;

  default_subLabel = '';
  charOrCell = @(x) ischar(x) || iscell(x);

  addRequired(p, 'opt');
  addOptional(p, 'subLabel', default_subLabel, charOrCell);

  parse(p, varargin{:});

  opt = p.Results.opt;
  subLabel = p.Results.subLabel;

  % outputs
  roiList = {};
  roiFolder = '';

  % in case user asked for specific ROIs
  roiNames = getRoiNames(opt);
  % We assume that the "label" of the roi filenames is requested in roiNames.
  % We return here to keep the behavior consistent with bids.query
  % that filters an entity out when asking for an empty entity.
  if strcmp(roiNames, '')
    return
  end

  % Identify if we are in MNI or individual space
  space = getSpace(opt);

  if strcmp(space, 'MNI')

    % here we don't expect BIDS name except from having a 'mask' suffix
    roiFolder = fullfile(opt.dir.roi, 'group');

    pattern = '';
    if ~isempty(roiNames)
      pattern = ['(' strjoin(roiNames, '|') '){1}'];
    end
    roiList = spm_select('FPlist', roiFolder, ['^.*' pattern '.*_mask.nii$']);
    roiList = cellstr(roiList);

  elseif strcmp(space, 'individual')

    % we expect ROI files to have BIDS valid names
    use_schema = false;
    BIDS_ROI = bids.layout(opt.dir.roi, use_schema);

    if strcmp(subLabel, '')
      msg = sprintf('Provide a subject label amongst those:\n%s\n\n', ...
                    createUnorderedList(bids.query(BIDS_ROI, 'subjects')));
      errorHandling(mfilename(), 'noSubject', msg, false, opt.verbosity > 0);
    end

    roiFolder = fullfile(BIDS_ROI.pth, ['sub-' subLabel], 'roi');

    filter = struct('sub', regexify(subLabel), ...
                    'space', opt.space);

    if ~isempty(roiNames)
      if iscell(roiNames) && (numel(roiNames) == 1 && ~strcmp(roiNames{1}, ''))
        filter.label = ['(' strjoin(opt.roi.name, '|') '){1}'];
      end
    end

    roiList = bids.query(BIDS_ROI, 'data', filter);

  end

end

function roiNames = getRoiNames(opt)
  roiNames = [];
  if isfield(opt, 'roi') && isfield(opt.roi, 'name')
    roiNames = opt.roi.name;
  end
end

function space = getSpace(opt)

  space = opt.space;

  if any(~cellfun('isempty', regexp(space, 'MNI'))) || ismember('IXI549Space', space)
    space = 'MNI';

  elseif strcmp(opt.space, 'individual')
    space = 'individual';

  else
    msg = sprintf('unknwon space:\n%s', createUnorderedList(space));
    errorHandling(mfilename(), 'unknownSpace', msg, false, opt.verbosity > 0);

  end

end
