% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSubjectLevelGLMSpec %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSubjectLevelGLMSpecBasic()

  funcFWHM = 6;
  subLabel = '01';
  iSes = 1;
  iRun = 1;

  opt = setOptions('MoAE', subLabel);
  opt.space = {'MNI'};

  bidsCopyInputFolder(opt);

  [BIDS, opt] = getData(opt, opt.dir.raw);

  % create dummy preprocessed data
  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});
  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);
  copyfile(fullfile(subFuncDataDir, fileName), ...
           fullfile(subFuncDataDir, ['s6wu', fileName]));

  % create dummy realign parameter file
  system(sprintf('touch %s', ...
                 fullfile(subFuncDataDir, ['rp_', strrep(fileName, '.nii', '.txt')])));

  matlabbatch = [];
  matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel, funcFWHM);

  % TODO add assert
  %     expectedBatch = returnExpectedBatch();
  %     assert(matlabbatch, returnExpectedBatch);

end

% function expectedBatch = returnExpectedBatch()
%
%     matlabbatch{1}.spm.stats.fmri_spec.dir = { outputDir};
%
%     matlabbatch{1}.spm.stats.fmri_spec.timing.RT = RT;
%     matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nbSlices;
%     matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = midSlice;
%
%     for iRun = 1:nbRuns
%
%         matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = { boldFileForFFX};
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).multi = { eventFile };
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).multi_reg = { confoundsFile };
%
%         % Things that are unlikely to change
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).hpf = 128;
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).regress = struct( ...
%                                                                       'name', {}, ...
%                                                                       'val', {});
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).cond = struct( ...
%                                                                    'name', {}, ...
%                                                                    'onset', {}, ...
%                                                                    'duration', {}, ...
%                                                                    'tmod', {}, ...
%                                                                    'pmod', {}, ...
%                                                                    'orth', {});
%     end
%
%     % Things that may change
%     matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = opt.model.hrfDerivatives;
%
%     matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
%
%     matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
%
%     matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
%
%     % Things that are unlikely to change
%     matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
%
%     matlabbatch{1}.spm.stats.fmri_spec.fact = struct( ...
%                                                      'name', {}, ...
%                                                      'levels', {});
%
%     matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
%     matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
%
% end
