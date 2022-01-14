function uninitCppSpm()
  %
  % Removes the added folders fromthe path for a given session.
  %
  % USAGE::
  %
  %   uninitCppSpm()
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDirectory = fileparts(mfilename('fullpath'));

  global CPP_SPM_INITIALIZED
  global CPP_SPM_PATHS

  if isempty(CPP_SPM_INITIALIZED) || ~CPP_SPM_INITIALIZED
    fprintf('\n\nCPP_SPM not initialized\n\n');
    return

  else
    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'uninitCppRoi'));
    rmpath(CPP_SPM_PATHS);
    spm('Clean');
    spm('Quit');

    if ~isOctave()
      clearvars -GLOBAL;
    end

  end

end
