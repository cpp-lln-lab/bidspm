% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_defaultResultsStructure %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_defaultResultsStructure_basic()

  results  = defaultResultsStructure();

  expected.nodeName =  '';

  expected.name = {''};

  expected.useMask = false();
  expected.MC = 'FWE';
  expected.p = 0.05;
  expected.k = 0;

  expected.png = false();

  expected.csv = false();

  expected.threshSpm = false();

  expected.binary = false();

  expected.montage.do = false();
  expected.montage.slices = [];
  expected.montage.orientation = 'axial';
  expected.montage.background = fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

  expected.nidm = false();

  assertEqual(results, expected);

end
