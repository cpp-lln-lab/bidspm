function mask = getInclusiveMask(opt, nodeName, BIDS, subLabel)
  %
  % Use the mask specified in the BIDS stats model as explicit mask.
  %
  % If none is specified and we are in MNI space,
  % then use the Intra Cerebral Volume SPM mask.
  %
  % USAGE::
  %
  %   mask = getInclusiveMask(opt, nodeName, BIDS, subLabel)
  %
  %

  % (C) Copyright 2022 bidspm developers

  bm = opt.model.bm;

  if nargin < 2
    [mask, nodeName] = bm.getModelMask();
  else
    [mask, nodeName] = bm.getModelMask('Name', nodeName);
  end

  node = bm.get_nodes('Name',  nodeName);

  % TODO refactor with bidsResults part for checking background for montage
  if isstruct(mask)

    if ismember(lower(node.Level), {'run', 'session', 'subject'})

      mask.sub = subLabel;
      mask.space = opt.space;
      file = bids.query(BIDS, 'data', mask);

      if iscell(file)

        if isempty(file)
          % let checkMaskOrUnderlay figure it out
          file = '';

        elseif numel(file) == 1
          file = file{1};

        elseif numel(file) > 1
          tmp = strrep(file, [BIDS.pth, filesep], '');
          tmp = bids.internal.format_path(tmp);
          msg = sprintf(['More than 1 mask image found in:\n %s\nfor filter: %s.\n\n' ...
                         'Taking the first one:\n\t%s\n\nfrom:%s'], ...
                        BIDS.pth, ...
                        bids.internal.create_unordered_list(mask), ...
                        tmp{1}, ...
                        bids.internal.create_unordered_list(tmp));
          id = 'tooManyMasks';
          logger('WARNING', msg, 'id', id, 'options', opt, 'filename', mfilename());
          file = file{1};

        else
          % ???

        end

      end

      mask = file;

    end

  end

  mask = checkMaskOrUnderlay(mask, opt, 'mask');

end
