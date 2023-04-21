function testDataDir = getTestDataDir(arg)
  %

  % (C) Copyright 2021 bidspm developers

  testDataDir = spm_file(fullfile(getTestDir(), 'data'), 'cpath');

  if nargin == 0 || isempty(arg)
    return
  elseif strcmpi(arg, 'raw')
    testDataDir = fullfile(getTestDataDir(), ['bidspm-' arg]);
  else
    testDataDir = fullfile(getTestDataDir(), 'derivatives', ['bidspm-' arg]);
  end

end
