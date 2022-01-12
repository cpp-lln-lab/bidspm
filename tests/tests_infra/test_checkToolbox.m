function test_suite = test_checkToolbox %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_checkToolbox_ali()

  if isGithubCi

    status = checkToolbox('ALI');

    assertEqual(status, false);

  end

end

function test_checkToolbox_macs()

  if ~isGithubCi

    if exist(fullfile(spm('dir'), 'toolbox', 'MACS'), 'dir')
      rmdir(fullfile(spm('dir'), 'toolbox', 'MACS'), 's');
    end

    status = checkToolbox('MACS');
    assertEqual(status, false);

  end

  status = checkToolbox('MACS', 'install', true);
  assertEqual(status, true);

end

function test_checkToolbox_unknow()

  assertWarning(@()checkToolbox('foo', 'verbose', true), ...
                'checkToolbox:unknownToolbox');

end
