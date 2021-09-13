function checkToolbox(toolboxName)
  %
  % Checks that that the right dependencies are installeda and
  % loads the spm defaults.
  %
  % USAGE::
  %
  %   checkToolbox()
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  global ALI_TOOLBOX_PRESENT

  ALI_TOOLBOX_PRESENT = false;

  if strcmp(toolboxName, 'ALI')
    % ALI toolbox
    if exist(fullfile(spm('dir'), 'toolbox', 'ALI'), 'dir')
      ALI_TOOLBOX_PRESENT =  true;
    end
  end

end
