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

  roiList = {};
  roiFolder = '';

  if strcmp(subLabel, '') || ...
      any(~cellfun('isempty', regexp(opt.space, 'MNI'))) || ...
      ismember('IXI549Space', opt.space)
    
    % here we don't expect BIDS name except from having a 'mask' suffix
    roiFolder = fullfile(opt.dir.roi, 'group');
    roiList = spm_select('FPlist', roiFolder, '^.*_mask.nii$');
    roiList = cellstr(roiList);

  elseif strcmp(opt.space, 'individual')
    
    % we expect ROI files to have BIDS valid names
    use_schema = false;
    BIDS_ROI = bids.layout(opt.dir.roi, use_schema);
    
    roiFolder = fullfile(BIDS_ROI.pth, ['sub-' subLabel], 'roi');
    
    roiList = bids.query(BIDS_ROI, 'data', ...
                         'sub', regexify(subLabel), ...
                         'space', opt.space);
    
  else

    msg = sprintf('unknwon space:\n%s', createUnorderedList(opt.space));
    errorHandling(mfilename(), 'unknownSpace', msg, true, opt.verbosity > 0);

  end

end