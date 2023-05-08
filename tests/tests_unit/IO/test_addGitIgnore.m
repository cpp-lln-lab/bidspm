function test_suite = test_addGitIgnore %#ok<*STOUT>
  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_addGitIgnore_basic()

  pth = tempName();

  addGitIgnore(pth);

  assertEqual(exist(fullfile(pth, '.gitignore'), 'file'), 2);

  fid = fopen(fullfile(pth, '.gitignore'), 'r');
  c = fread(fid, Inf, 'uint8=>char')';

  assertEqual(strfind(c, '.DS_store'), 1);

  fclose(fid);

end

function test_addGitIgnore_already_present()

  pth = tempName();

  fid = fopen(fullfile(pth, '.gitignore'), 'w');
  fprintf(fid, 'foo\n');
  fprintf(fid, '.DS_store\n');
  fclose(fid);

  addGitIgnore(pth);

  fid = fopen(fullfile(pth, '.gitignore'), 'r');
  c = fread(fid, Inf, 'uint8=>char')';
  assertEqual(numel(strfind(c, '.DS_store')), 1);

  fclose(fid);

end

function test_addGitIgnore_append()

  if bids.internal.is_octave() || ispc || ismac
    moxunit_throw_test_skipped_exception( ...
                                         'Waiting for fix on octave, windows and mac.');
  end

  pth = tempName();

  fid = fopen(fullfile(pth, '.gitignore'), 'w');
  fprintf(fid, 'foo\n');
  fprintf(fid, 'bar\n');
  fclose(fid);

  addGitIgnore(pth);

  fid = fopen(fullfile(pth, '.gitignore'), 'r');
  c = fread(fid, Inf, 'uint8=>char')';
  assert(strfind(c, '.DS_store') > 0);
  fclose(fid);

end
