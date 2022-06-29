function test_suite = test_setNidm %#ok<*STOUT>
  %
  % (C) Copyright 2020 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setNidm_basic()

  export = [];
  result.nidm = false;
  export = setNidm(export, result);
  assertEqual(export, []);

end

function test_setNidm_individual()

  export = [];

  result.nidm = true;
  result.space = 'individual';
  result.nbSubj = 1;
  result.label = 'GROUP';

  export = setNidm(export, result);

  expected = struct('modality', 'FMRI', ...
                    'refspace',  'subject', ...
                    'group', struct('label', 'GROUP', ...
                                    'nsubj', 1));

  assertEqual(export{1}.nidm, expected);

end

function test_setNidm_IXI549Space()

  export = [];

  result.nidm = true;
  result.space = 'IXI549Space';
  result.nbSubj = 10;
  result.label = 'GROUP';

  export = setNidm(export, result);

  expected = struct('modality', 'FMRI', ...
                    'refspace',  'ixi', ...
                    'group', struct('label', 'GROUP', ...
                                    'nsubj', 10));

  assertEqual(export{1}.nidm, expected);

end
