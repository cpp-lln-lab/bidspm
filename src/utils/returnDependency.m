function dep = returnDependency(opt, type)
  %
  % Use to create dependencies between batches in workflows.
  %
  % USAGE::
  %
  %  dep = returnDependency(opt, type)
  %

  % (C) Copyright 2021 bidspm developers

  handledDependencies = {'segment', 'skullStripping', 'skullStrippingMask'...
                         'coregister', 'selectAnat', 'realign', ...
                         'MACS_model_space', 'MACS_BMS_group_auto', ...
                         'mean', 'smooth', 'mask', 'maskedMean', 'rename'};

  switch type

    case {'segment', 'skullStripping', 'mean', 'smooth', 'mask', 'maskedMean', ...
          'skullStrippingMask'}
      dep = substruct('.', 'val', '{}', {opt.orderBatches.(type)}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1});

    case {'coregister', 'selectAnat', 'realign', ...
          'MACS_model_space', 'MACS_BMS_group_auto', 'rename'}
      dep = substruct('.', 'val', '{}', {opt.orderBatches.(type)}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1});

    otherwise
      dep = '';

      msg = sprintf('unknown batch dependency requested: %s\nHandled dependencies:\n%s\n\n', ...
                    type, ...
                    createUnorderedList(handledDependencies));
      id = 'unknownDependency';
      logger('ERROR', msg, 'id', id, 'filename', mfilename());

  end

end
