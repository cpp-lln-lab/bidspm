function dummyDataDir = getDummyDataDir(arg)
  %

  % (C) Copyright 2021 bidspm developers

  dummyDataDir = spm_file(fullfile(getTestDir(), 'dummyData'), 'cpath');

  if nargin == 0 || isempty(arg)
    return
  elseif strcmpi(arg, 'raw')
    dummyDataDir = fullfile(getDummyDataDir(), ['bidspm-' arg]);
  else
    dummyDataDir = fullfile(getDummyDataDir(), 'derivatives', ['bidspm-' arg]);
  end

end
