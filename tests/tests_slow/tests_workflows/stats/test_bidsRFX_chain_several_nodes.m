% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX_chain_several_nodes %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_no_overwrite()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vismotionNoOverWrite_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  opt.ignore = {'qa'};

  matlabbatch = bidsRFX('RFX', opt);

  % 2 simple dummy contrasts
  % 1 complex
  % 8 within group: 4 contrast from run level * 2 groups
  % 4 between group: 4 contrast from run level * 1 group comparison
  % but only the last 4 are returned
  expected_nb_dsigns = 2 + 1 + 8 + 4;
  summary = batchSummary(matlabbatch);
  nb_designs = sum(sum(cellfun(@(x) strcmp(x, 'factorial_design'), summary)));

  assertEqual(nb_designs, 4);

  %   folders = {};
  %   for i = 1:numel(matlabbatch)
  %       if isfield(matlabbatch{i}.spm, 'stats') && ...
  %             isfield(matlabbatch{i}.spm.stats, 'factorial_design')
  %           [~, tmp] = fileparts(matlabbatch{i}.spm.stats.factorial_design.dir{1});
  %           folders{end+1, 1} = tmp;
  %
  %       end
  %   end
  %   folders

end

function test_bidsRFX_several_datasets_level()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  summary = batchSummary(matlabbatch);
  nb_designs = sum(sum(cellfun(@(x) strcmp(x, 'factorial_design'), summary)));

  % 2 simple dummy contrasts and one complex
  % but only the last one is returned
  assertEqual(nb_designs, 1);
end

function value = batchSummary(matlabbatch)
  value = {};
  for i = 1:numel(matlabbatch)
    field = fieldnames(matlabbatch{i}.spm);
    value{i, 1} = field{1}; %#ok<*AGROW>
    field = fieldnames(matlabbatch{i}.spm.(value{i, 1}));
    value{i, 2} = field{1};
  end
end
