% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_transformers
  %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end


function test_getBidsTransformers_basic()

  opt = setOptions('vismotionWithTransformation');

  transformers = getBidsTransformers(opt.model.file);

  assert(isstruct(transformers));

  expected(1, 1).Name = 'Subtract';
  expected(1).Input = {'trial_type.VisMot'};
  expected(1).Value = 3;
  expected(1).Output = {'VisMot'};
  expected(2, 1).Name = 'Add';
  expected(2).Input = {'trial_type.VisStat'};
  expected(2).Value = 1;
  expected(2).Output = {'VisStat'};

  assertEqual(transformers(1), expected(1));
  assertEqual(transformers(2), expected(2));

end
