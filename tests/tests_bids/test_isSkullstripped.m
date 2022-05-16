% (C) Copyright 2022 CPP_SPM developers

function test_suite = test_isSkullstripped %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_isSkullstripped_basic()

  bf = bids.File('sub-01_T1w', 'use_schema', false);

  status = isSkullstripped(bf);

  assert(~status);

end

function test_isSkullstripped_entity()

  bf = bids.File('sub-01_desc-skullstripped_T1w', 'use_schema', false);

  status = isSkullstripped(bf);

  assert(status);

end

function test_isSkullstripped_metadata()

  bf = bids.File('sub-01_T1w', 'use_schema', false);
  bf.metadata.SkullStripped = true;

  status = isSkullstripped(bf);

  assert(status);

end
