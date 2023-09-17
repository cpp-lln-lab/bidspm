function markTestAs(label)
  %
  % USAGE::
  %
  %   markTestAs(label)
  %
  %

  % (C) Copyright 2023 bidspm developers

  switch lower(label)
    case 'slow'
      if ~usingSlowTestMode()
        moxunit_throw_test_skipped_exception('slow test only');
      end
  end

end
