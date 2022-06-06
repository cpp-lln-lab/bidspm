function ffxDir = getFFXdir(subLabel, opt)
  %
  % Sets the name the FFX directory and creates it if it does not exist
  %
  % USAGE::
  %
  %   ffxDir = getFFXdir(subLabel, opt)
  %
  % :param subLabel:
  % :type subLabel: string
  %
  % :param opt:
  % :param opt: structure
  %
  % :returns: - :ffxDir: (string)
  %
  % (C) Copyright 2019 CPP_SPM developers

  glmDirName = createGlmDirName(opt);

  if ~isfield(opt.model, 'bm')
    opt.model.bm = BidsModel('file', opt.model.file);
    if strcmpi(opt.pipeline.type, 'stats')
      opt = getOptionsFromModel(opt);
    end
  end

  % folder naming based on the rootNode name
  rootNode = opt.model.bm.getRootNode();
  nodeName = rootNode.Name;

  if ~isempty(nodeName) && ~strcmpi(nodeName, 'run_level')
    glmDirName = [glmDirName, '_desc-', bids.internal.camel_case(nodeName)];
  end

  ffxDir = fullfile(opt.dir.stats, ...
                    ['sub-', deregexify(subLabel)], ...
                    glmDirName);

  if opt.glm.roibased.do
    ffxDir = [ffxDir '_roi'];
  end

  spm_mkdir(ffxDir);

end

function string = deregexify(string)
  % remove any non alphanumeric characters
  string = regexprep(string, '[^a-zA-Z0-9]+', '');
end
