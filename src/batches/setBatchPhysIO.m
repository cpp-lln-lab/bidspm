% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchPhysIO(matlabbatch, BIDS, opt, subID, info, varargin)
  %
  % template to creae new setBatch functions
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subID, info, varargin)
  %
  % :param matlabbatch:
  % :type matlabbatch:
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job

  printBatchName('create phsysiolocal regressors');

  matlabbatch{end + 1}.spm.tools.physio.save_dir = {'physio_out'};

  matlabbatch{end}.spm.tools.physio.log_files.vendor = 'BIDS'; % DEFAULT FOR BIDS
  matlabbatch{end}.spm.tools.physio.log_files.cardiac = {'sub-s999_task-random_run-99_physio.tsv.gz'};
  matlabbatch{end}.spm.tools.physio.log_files.respiration = {''}; % DEFAULT FOR BIDS
  matlabbatch{end}.spm.tools.physio.log_files.scan_timing = {''}; % DEFAULT FOR BIDS
  matlabbatch{end}.spm.tools.physio.log_files.sampling_interval = []; % DEFAULT FOR BIDS
  matlabbatch{end}.spm.tools.physio.log_files.relative_start_acquisition = 0; % DEFAULT FOR BIDS
  matlabbatch{end}.spm.tools.physio.log_files.align_scan = 'first'; % DEFAULT FOR BIDS

  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.Nslices = 16;

  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = []; % DEFAULT FOR BIDS

  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.TR = 1.45;

  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0; % DEFAULT FOR BIDS

  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.Nscans = 408;

  % from the gui doc:
  %  Slice to which regressors are temporally aligned
  %  Tipically the slice where your most important activationn is expected.
  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.onset_slice = 9;

  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = []; % DEFAULT TR/Nslices
  matlabbatch{end}.spm.tools.physio.scan_timing.sqpar.Nprep = []; % DEFAULT
  matlabbatch{end}.spm.tools.physio.scan_timing.sync.scan_timing_log = struct([]); % DEFAULT FOR BIDS
  matlabbatch{end}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
  matlabbatch{end}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
  matlabbatch{end}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
  matlabbatch{end}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);

  matlabbatch{end}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';

  matlabbatch{end}.spm.tools.physio.model.output_physio = 'physio.mat';

  matlabbatch{end}.spm.tools.physio.model.orthogonalise = 'none';

  matlabbatch{end}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
  matlabbatch{end}.spm.tools.physio.model.retroicor.yes.order.c = 3;
  matlabbatch{end}.spm.tools.physio.model.retroicor.yes.order.r = 4;
  matlabbatch{end}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
  matlabbatch{end}.spm.tools.physio.model.rvt.no = struct([]);
  matlabbatch{end}.spm.tools.physio.model.hrv.no = struct([]);
  matlabbatch{end}.spm.tools.physio.model.noise_rois.no = struct([]);
  matlabbatch{end}.spm.tools.physio.model.movement.no = struct([]);
  matlabbatch{end}.spm.tools.physio.model.other.no = struct([]);
  matlabbatch{end}.spm.tools.physio.verbose.level = 3;

  matlabbatch{end}.spm.tools.physio.verbose.fig_output_file = 'fig.png';

  matlabbatch{end}.spm.tools.physio.verbose.use_tabs = false;

end
