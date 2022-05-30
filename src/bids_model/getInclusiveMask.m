function mask = getInclusiveMask(opt, nodeName, BIDS, subLabel)
  %
  % use the mask specified in the BIDS stats model as explicit mask
  %
  % if none is specified and we are in MNI space
  % we use the Intra Cerebal Volume SPM mask
  %
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  if nargin < 2
    [mask, nodeName] = opt.model.bm.getModelMask();
  else
    [mask, nodeName] = opt.model.bm.getModelMask('Name', nodeName);
  end

  node = opt.model.bm.get_nodes('Name',  nodeName);
  if iscell(node)
    node = node{1};
  end

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
          msg = sprintf('More than 1 mask image found for %s.\n Taking the first one.', ...
                        createUnorderedList(mask));
          id = 'tooManyMasks';
          errorHandling(mfilename(), id, msg, true, opt.verbosity);
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
