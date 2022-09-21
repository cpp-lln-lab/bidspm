function dummyDataDir = getDummyDataDir(arg)
  %

  % (C) Copyright 2021 bidspm developers

  dummyDataDir = spm_file(fullfile(getTestDir(), 'dummyData'), 'cpath');

  if nargin == 0 || isempty(arg)
    return
  elseif strcmpi(arg, 'raw')
    dummyDataDir = fullfile(getDummyDataDir(), ['cpp_spm-' arg]);
  else
    dummyDataDir = fullfile(getDummyDataDir(), 'derivatives', ['cpp_spm-' arg]);
  end

end
