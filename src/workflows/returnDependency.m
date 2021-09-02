function dep = returnDependency(opt, type)
  %
  % USAGE::
  %
  %  dep = returnDependency(opt, type)
  %
  % (C) Copyright 2021 CPP_SPM developers

  switch type

    case {'segment', 'skullStripping'}
      dep = substruct('.', 'val', '{}', {opt.orderBatches.(type)}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1});

    case {'coregister', 'selectAnat', 'realign'}
      dep = substruct('.', 'val', '{}', {opt.orderBatches.(type)}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1});
    otherwise
      dep = '';

  end

end
