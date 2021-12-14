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
  content.BIDSModelVersion =  '1.0.0';
  content.Description = ' ';
  content.Input = struct('task', ' ');
  content.Nodes = {createEmptyNode('run'); ...
                   createEmptyNode('subject'); ...
                   createEmptyNode('dataset')};

  content.Nodes{3} = rmfield(content.Nodes{3}, {'Transformations'});
  content.Nodes{3}.Model.Software.SPM = rmfield(content.Nodes{3}.Model.Software.SPM, 'whitening');
  content.Nodes{3}.Model.Options = rmfield(content.Nodes{3}.Model.Options, ...
                                           'HighPassFilterCutoffHz');

end
