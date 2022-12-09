function [roiList, roiFolder] = getROIs(varargin)
  %
  % Get the rois from :
  %
  % - the group folder when running analysis in MNI space
  % - the ``sub-*/roi/sub-subLabel`` folder when in individual space
  %
  % USAGE::
  %
  %   [roiList, roiFolder] = getROIs(opt, subLabel)
  %
  %

  % (C) Copyright 2021 bidspm developers

  args = inputParser;

  defaultSubLabel = '';
  charOrCell = @(x) ischar(x) || iscell(x);

  addRequired(args, 'opt');
  addOptional(args, 'subLabel', defaultSubLabel, charOrCell);

  parse(args, varargin{:});

  opt = args.Results.opt;
  subLabel = args.Results.subLabel;

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
      if numel(roiNames) > 1
        pattern = ['(' strjoin(roiNames, '|') '){1}'];
      else
        pattern = roiNames{1};
      end
    end
    pattern = [pattern '.*_mask.nii'];
    pattern = regexify(pattern);
    roiList = spm_select('FPlist', roiFolder, pattern);
    roiList = cellstr(roiList);

  else

    % we expect ROI files to have BIDS valid names
    BIDS_ROI = bids.layout(opt.dir.roi, 'use_schema', false);

    if strcmp(subLabel, '')
      msg = sprintf('Provide a subject label amongst those:\n%s\n\n', ...
                    createUnorderedList(bids.query(BIDS_ROI, 'subjects')));
      id = 'noSubject';
      logger('ERROR', msg, 'filaneme', mfilename(), 'id', id);
    end

    filter = opt.bidsFilterFile.roi;
    filter.sub = regexify(subLabel);

    if ~isempty(roiNames)
      if iscell(roiNames)
        if ~(numel(roiNames) == 1 && ~strcmp(roiNames{1}, ''))
        else
          filter.label = ['(' strjoin(opt.roi.name, '|') '){1}'];
        end

      elseif isstruct(roiNames)
        filter = setFields(filter, opt.roi.name);

      end

    end

    roiList = bids.query(BIDS_ROI, 'data', filter);

    % assuming all ROIs are in the same folder
    if ~isempty(roiList)
      roiFolder = fileparts(roiList{1});
    else
      roiFolder = [];
    end

  end

end

function roiNames = getRoiNames(opt)
  roiNames = [];
  if isfield(opt, 'roi') && isfield(opt.roi, 'name')
    roiNames = opt.roi.name;
  end
end

function space = getSpace(opt)

  space = opt.bidsFilterFile.roi.space;

  if ~iscell(space)
    space = {space};
  end

  if any(~cellfun('isempty', regexp(space, 'MNI'))) || ismember('IXI549Space', space)
    space = 'MNI';
  end

end
