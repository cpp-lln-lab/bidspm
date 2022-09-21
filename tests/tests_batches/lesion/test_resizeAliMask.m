function test_suite = test_resizeAliMask %#ok<*STOUT>

  % (C) Copyright 2021 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_resizeAliMask_basic()

  subLabel = '01';
  opt = setOptions('MoAE', subLabel, 'useRaw', true);

  if isGithubCi
    return
  else
    opt = setFields(opt, ALI_my_defaults());
  end

  opt.toolbox.ALI.unified_segmentation.step1vox = 1.2;
  aliMask = resizeAliMask(opt);

  expected =     fullfile(spm('dir'), ...
                          'toolbox', ...
                          'ALI', ...
                          'Mask_image', ...
                          'mask_controls_vox1.2mm.nii');

  assertEqual(aliMask, expected);
  assertEqual(exist(expected, 'file'), 2);

  delete(aliMask);

end
