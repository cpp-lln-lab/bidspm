function test_suite = test_checkToolbox %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_checkToolbox_mp2rage()

  status = checkToolbox('mp2rage');

  assertEqual(status, isdir(fullfile(spm('dir'), 'toolbox', 'mp2rage')));

  if bids.internal.is_octave()
    %       'Octave:mixed-string-concat'
    return
  end

  if ~isdir(fullfile(spm('dir'), 'toolbox', 'mp2rage'))
    assertWarning(@()checkToolbox('mp2rage', 'verbose', true), ...
                  'checkToolbox:missingToolbox');
  end

end

function test_checkToolbox_ali()

  if bids.internal.is_github_ci()

    status = checkToolbox('ALI');

    assertEqual(status, false);

  end

end

function test_checkToolbox_macs()

  if ~bids.internal.is_github_ci()

    if exist(fullfile(spm('dir'), 'toolbox', 'MACS'), 'dir')
      rmdir(fullfile(spm('dir'), 'toolbox', 'MACS'), 's');
    end

    status = checkToolbox('MACS');
    assertEqual(status, false);

    status = checkToolbox('MACS', 'install', true);
    assertEqual(status, true);

  else

    if bids.internal.is_octave()
      return
    end

    status = checkToolbox('MACS');
    assertEqual(status, true);

  end

end

function test_checkToolbox_unknow()

  assertWarning(@()checkToolbox('foo', 'verbose', true), ...
                'checkToolbox:unknownToolbox');

end
