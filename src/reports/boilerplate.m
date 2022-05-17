function outputFile = boilerplate(pipelineType, opt, outputPath)
  %
  % (C) Copyright 2022 CPP_SPM developers

  if strcmp(pipelineType, 'spatial_preproc')
    fileToRender = fullfile(fileparts(mfilename('fullpath')), 'boilerplate_preprocess.mustache');
    outputFile = fullfile(outputPath, 'preprocess.md');
  end

  partialsPath = fullfile(fileparts(mfilename('fullpath')), 'partials');

  [OS, generatedBy] = getEnvInfo(opt);

  opt.OS = OS;

  if strcmp(OS.name, 'GLNXA64')
    opt.OS.name = 'unix';
  end

  opt.generatedBy = generatedBy;

  if ismember('IXI549Space', opt.space)
    opt.normalization = true;
  else
    opt.normalization = false;
  end

  if opt.realign.useUnwarp
    opt.unwarp = true;
  else
    opt.unwarp = false;
  end

  if opt.fwhm.func == 0
    opt.smoothing = false;
  else
    opt.smoothing = true;
  end

  output = octache(fileToRender, ...
                   'data', opt, ...
                   'partials_path', partialsPath, ...
                   'partials_ext', 'mustache', ...
                   'l_del', '{{', ...
                   'r_del', '}}', ...
                   'warn', true, ...
                   'keep', true);

  fid = fopen(outputFile, 'wt');
  if fid == -1
    error('Unable to open file "%s" for writing.', filename);
  end
  fprintf(fid, '%s', output);
  fclose(fid);

end
