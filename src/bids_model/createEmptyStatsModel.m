function content = createEmptyStatsModel()
  %
  % Creates the content of a basic model.json file for GLM analysis with
  % some default options like high pass filter cut-off
  % and the type of autocorrelation correction.
  %
  % USAGE::
  %
  %   content = createEmptytModelBasic()
  %
  % :returns:
  %
  % - :content: structure containing the output that can be saved with
  %             ``spm_jsonwrite()``. See below.
  %
  % EXAMPLE::
  %
  %   jsonOptions.indent = '   ';
  %   content = createEmptytModelBasic()
  %   filename = fullfile(pwd, 'models', 'model-empty_smdl.json')
  %   spm_jsonwrite(filename, content, jsonOptions);
  %
  % (C) Copyright 2020 CPP_SPM developers

  content.Name = ' ';
  content.Description = ' ';
  content.Input = struct('task', ' ');
  content.Steps = {createEmptyNode('run'); ...
                   createEmptyNode('subject'); ...
                   createEmptyNode('dataset')};

  content.Steps{3} = rmfield(content.Steps{3}, {'Transformations'});
  content.Steps{3}.Model.Software.SPM = rmfield(content.Steps{3}.Model.Software.SPM, 'whitening');
  content.Steps{3}.Model.Options = rmfield(content.Steps{3}.Model.Options, ...
                                           'high_pass_filter_cutoff_secs');

end
