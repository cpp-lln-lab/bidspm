function dep = returnDependency(opt, type)
  %
  % Use to create dependencies between batches in workflows.
  %
  % USAGE::
  %
  %  dep = returnDependency(opt, type)
  %
  % (C) Copyright 2021 CPP_SPM developers

  handledDependencies = {'segment', 'skullStripping', ...
                         'coregister', 'selectAnat', 'realign', ...
                         'MACS_model_space', 'MACS_BMS_group_auto'};

  switch type

    case {'segment', 'skullStripping'}
      dep = substruct('.', 'val', '{}', {opt.orderBatches.(type)}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1});

    case {'coregister', 'selectAnat', 'realign', 'MACS_model_space', 'MACS_BMS_group_auto'}
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
      errorHandling(mfilename(), id, msg, false, opt.verbosity);

  end

end
