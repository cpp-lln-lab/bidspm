function test_suite = test_boilerplate %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_boilerplate_spatial_preproc()

  % GIVEN

  opt = setOptions('MoAE-preproc');

  filter = opt.bidsFilterFile.bold;
  filter.task = opt.taskName;

  %   sliceOrder = getAndCheckSliceOrder(opt.dir.input, opt, filter);
  %   if isempty(sliceOrder)
  %     opt.stc = false;
  %   end

  opt.stc.referenceSlice = 16;

  %   opt.dummy_scans = false;
  opt.dummy_scans.nb = 4;

  %  opt.space = {'individual'};

  %  opt.realign.useUnwarp = false;

  %  opt.fwhm.func = 0;

  boilerplate(opt, pwd, 'spatial_preproc');
  

end
