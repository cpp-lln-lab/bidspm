% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function dowloadAndConvertFaceRep()
  %
  % downloads the fare repetition dataset from SPM and convert it to BIDS
  %
  % Adapted from its counterpart for MoAE
  % <https://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAE_convert2bids.m>
  %

  subject = 'sub-01';
  task_name = 'face repetition';
  nb_slices = 24;
  repetition_time = 2;
  echo_time = 0.04;

  opt.indent = '  ';

  % URL of the data set to download
  URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/face_rep/face_rep.zip';

  working_directory = fileparts(mfilename('fullpath'));
  input_dir = fullfile(working_directory, 'inputs', 'source');
  output_dir = fullfile(working_directory, 'outputs', 'raw');
  
  % clean previous runs
  try
      rmdir(input_dir, 's');
      rmdir(output_dir, 's');
  catch
  end
  spm_mkdir(fullfile(working_directory, 'inputs'));
  spm_mkdir(output_dir);

  %% Get data
  fprintf('%-10s:', 'Downloading dataset...');
  urlwrite(URL, 'face_rep.zip');
  fprintf(1, ' Done\n\n');
  
  fprintf('%-10s:', 'Unzipping dataset...');
  unzip('face_rep.zip');
  movefile('face_rep', fullfile(working_directory, 'inputs', 'source'));
  fprintf(1, ' Done\n\n');

  %% Create ouput folder structure
  spm_mkdir(output_dir, subject, {'anat', 'func'});

  %% Structural MRI
  anat_hdr = spm_vol(fullfile(input_dir, 'Structural', 'sM03953_0007.img'));
  anat_data  = spm_read_vols(anat_hdr);
  anat_hdr.fname = fullfile(output_dir, 'sub-01', 'anat', 'sub-01_T1w.nii');
  spm_write_vol(anat_hdr, anat_data);

  %% Functional MRI
  func_files = spm_select('FPList', fullfile(input_dir, 'RawEPI'), '^sM.*\.img$');
  spm_file_merge( ...
                 func_files, ...
                 fullfile(output_dir, 'sub-01', 'func', ...
                          ['sub-01_task-' strrep(task_name, ' ', '') '_bold.nii']), ...
                 0, ...
                 repetition_time);
  delete(fullfile(output_dir, 'sub-01', 'func', ...
                  ['sub-01_task-' strrep(task_name, ' ', '') '_bold.mat']));

  %% And everything else
  create_events_tsv_file(input_dir, output_dir, task_name, repetition_time);
  create_readme(output_dir);
  create_changelog(output_dir);
  create_datasetdescription(output_dir, opt);
  create_bold_json(output_dir, task_name, repetition_time, nb_slices, echo_time, opt);

end

function create_events_tsv_file(input_dir, output_dir, task_name, repetition_time)

  % TODO
  % add the lag between presentations of each item necessary for the parametric
  % analysis.

  load(fullfile(input_dir, 'all_conditions.mat'), ...
       'names', 'onsets', 'durations');

  onset_column = [];
  duration_column = [];
  trial_type_column = [];

  for iCondition = 1:numel(names)
    onset_column = [onset_column; onsets{iCondition}]; %#ok<*USENS>
    duration_column = [duration_column; durations{iCondition}']; %#ok<*AGROW>
    trial_type_column = [trial_type_column; repmat( ...
                                                   names{iCondition}, ...
                                                   size(onsets{iCondition}, 1), 1)];
  end

  % sort trials by their presentation time
  [onset_column, idx] = sort(onset_column);
  duration_column = duration_column(idx);
  trial_type_column = trial_type_column(idx, :);

  onset_column = repetition_time * onset_column;

  tsv_content = struct( ...
                       'onset', onset_column, ...
                       'duration', duration_column, ...
                       'trial_type', {cellstr(trial_type_column)});

  spm_save(fullfile(output_dir, 'sub-01', 'func', ...
                    ['sub-01_task-' strrep(task_name, ' ', '') '_events.tsv']), ...
           tsv_content);

end

function create_readme(output_dir)

  rdm = {
         ' ___  ____  __  __'
         '/ __)(  _ \(  \/  )  Statistical Parametric Mapping'
         '\__ \ )___/ )    (   Wellcome Centre for Human Neuroimaging'
         '(___/(__)  (_/\/\_)  https://www.fil.ion.ucl.ac.uk/spm/'

         ''
         '               Face repetition example event-related fMRI dataset'
         '________________________________________________________________________'
         ''
         '???'
         ''
         'Summary:'
         '7 Files, 79.32MB'
         '1 - Subject'
         '1 - Session'
         ''
         'Available Tasks:'
         'face repetition'
         ''
         'Available Modalities:'
         'T1w'
         'bold'
         'events'
         ''
         'These whole brain BOLD/EPI images were acquired on a modified ???T'
         'Siemens MAGNETOM Vision system.'
         '351 acquisitions were made.'
         'Each EPI acquisition consisted of 24 descending slices:'
         '- matrix size: 64x64'
         '- voxel size: 3mm x 3mm x 3mm with 1.5mm gap'
         '- repatition time: 2s'
         '- echo time: 40ms'
         ''
         'Experimental design:'
         '- 2x2 factorial event-related fMRI'
         '- One session (one subject)'
         '- (Famous vs. Nonfamous) x (1st vs 2nd presentation) of faces '
         '  against baseline of chequerboard'
         '- 2 presentations of 26 Famous and 26 Nonfamous Greyscale photographs, '
         '  for 0.5s, randomly intermixed, for fame judgment task '
         '  (one of two right finger key presses).'
         '- Parameteric factor "lag" = number of faces intervening '
         '  between repetition of a specific face + 1'
         '- Minimal SOA=4.5s, with probability 2/3 (ie 1/3 null events)'
         ''
         'A structural image was also acquired.'};

  % TODO
  % use spm_save to actually write this file?
  fid = fopen(fullfile(output_dir, 'README'), 'wt');
  for i = 1:numel(rdm)
    fprintf(fid, '%s\n', rdm{i});
  end
  fclose(fid);

end

function create_changelog(output_dir)

  cg = { ...
        '1.0.1 2020-11-26', ' - BIDS version.', ...
        '1.0.0 1999-05-13', ' - Initial release.'};
  fid = fopen(fullfile(output_dir, 'CHANGES'), 'wt');

  for i = 1:numel(cg)
    fprintf(fid, '%s\n', cg{i});
  end
  fclose(fid);

end

function create_datasetdescription(output_dir, opt)

  descr = struct( ...
                 'BIDSVersion', '1.4.0', ...
                 'Name', 'Mother of All Experiments', ...
                 'Authors', {{ ...
                              'Henson, R.N.A.', ...
                              'Shallice, T.', ...
                              'Gorno-Tempini, M.-L.', ...
                              'Dolan, R.J.'}}, ...
                 'ReferencesAndLinks', ...
                 {{'https://www.fil.ion.ucl.ac.uk/spm/data/face_rep/', ...
                   ['Henson, R.N.A., Shallice, T., Gorno-Tempini, M.-L. ' ...
                    'and Dolan, R.J. (2002),', ...
                    'Face repetition effects in implicit and explicit memory tests as', ...
                    'measured by fMRI. Cerebral Cortex, 12, 178-186.'], ...
                   'doi:10.1093/cercor/12.2.178'}} ...
                );

  spm_save(fullfile(output_dir, 'dataset_description.json'), ...
           descr, ...
           opt);

end

function create_bold_json(output_dir, task_name, repetition_time, nb_slices, echo_time, opt)

  acquisition_time = repetition_time - repetition_time / nb_slices;
  slice_timing = linspace(acquisition_time, 0, nb_slices);

  task = struct( ...
                'RepetitionTime', repetition_time, ...
                'EchoTime', echo_time, ...
                'SliceTiming', slice_timing, ...
                'NumberOfVolumesDiscardedByScanner', 0, ...
                'NumberOfVolumesDiscardedByUser', 0, ...
                'TaskName', task_name, ...
                'TaskDescription', ...
                ['2 presentations of 26 Famous and 26 Nonfamous Greyscale photographs, ', ...
                 'for 0.5s, randomly intermixed, for fame judgment task ', ...
                 '(one of two right finger key presses).'], ...
                'Manufacturer', 'Siemens', ...
                'ManufacturersModelName', 'MAGNETOM Vision', ...
                'MagneticFieldStrength', 2);

  spm_save(fullfile(output_dir, ...
                    ['task-' strrep(task_name, ' ', '') '_bold.json']), ...
           task, ...
           opt);

end
