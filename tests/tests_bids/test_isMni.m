% (C) Copyright 2022 CPP_SPM developers

function test_suite = test_isMni %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_isMni_basic()

  space = {'IXI549Space'
           'mni'
           'MNIColin27'
           'MNI152NLin2009aSym'
           'MNI152Lin'
           'MNI152NLin6Sym'
           'MNI152NLin6ASym'
           'MNI305'
           'ICBM452AirSpace'
           'ICBM452Warp5Space'
           'foo'
           'MNI_but_not'
          };

  idx = isMni(space);

  assertEqual(idx, [true(10, 1); false(2, 1)]);

end
