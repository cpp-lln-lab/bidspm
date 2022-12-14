% (C) Copyright 2020 bidspm developers

function test_suite = test_addGitIgnore %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_addGitIgnore_basic()

  if exist(fullfile(pwd, '.gitignore'), 'file')
    delete(fullfile(pwd, '.gitignore'));
  end

  addGitIgnore(pwd);

  assertEqual(exist(fullfile(pwd, '.gitignore'), 'file'), 2);

  fid = fopen(fullfile(pwd, '.gitignore'), 'r');
  c = fread(fid, Inf, 'uint8=>char')';

  assertEqual(strfind(c, '.DS_store'), 1);

  fclose(fid);

  delete(fullfile(pwd, '.gitignore'));

end

function test_addGitIgnore_already_present()

  if exist(fullfile(pwd, '.gitignore'), 'file')
    delete(fullfile(pwd, '.gitignore'));
  end
  fid = fopen(fullfile(pwd, '.gitignore'), 'w');
  fprintf(fid, 'foo\n');
  fprintf(fid, '.DS_store\n');
  fclose(fid);

  addGitIgnore(pwd);

  fid = fopen(fullfile(pwd, '.gitignore'), 'r');
  c = fread(fid, Inf, 'uint8=>char')';
  assertEqual(numel(strfind(c, '.DS_store')), 1);

  fclose(fid);

  delete(fullfile(pwd, '.gitignore'));
end

function test_addGitIgnore_append()

  if isOctave()
    return
  end

  if exist(fullfile(pwd, '.gitignore'), 'file')
    delete(fullfile(pwd, '.gitignore'));
  end

  fid = fopen(fullfile(pwd, '.gitignore'), 'w');
  fprintf(fid, 'foo\n');
  fprintf(fid, 'bar\n');
  fclose(fid);

  addGitIgnore(pwd);

  fid = fopen(fullfile(pwd, '.gitignore'), 'r');
  c = fread(fid, Inf, 'uint8=>char')';
  assert(strfind(c, '.DS_store') > 0);
  fclose(fid);

  delete(fullfile(pwd, '.gitignore'));
end
