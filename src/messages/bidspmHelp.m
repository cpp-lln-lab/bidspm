function bidspmHelp()
  %
  % General intro function for bidspm
  %
  %
  % Note::
  %
  %   - all parameters use ``snake_case``
  %   - most "invalid" calls simply initialize bidspm
  %
  %
  %
  % **BIDS APP CALLS**
  %
  % generic call:
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, analysis_level, ...
  %           'action', 'some_action', ...
  %           'participant_label', {}, ...
  %           'task', {}, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'options', struct([]))
  %
  %
  % *Obligatory parameters*
  %
  % :param bids_dir:        path to a raw BIDS dataset
  % :type  bids_dir:        path
  %
  % :param output_dir:      path where to output data
  % :type  output_dir:      path
  %
  % :param analysis_level:  Can either be ``'subject'`` or ``'dataset'``.
  %                         Defaults to ``'subject'``
  % :type  analysis_level:  string
  %
  % :type action:           char
  % :param action:          defines the pipeline to run; can be any of:
  %
  %    - ``'copy'``: copies fmriprep data for smoothing
  %    - ``'preprocess'``: preprocesses data
  %    - ``'smooth'``: smooths data
  %    - ``'default_model'``: creates a default BIDS stats model
  %    - ``'create_roi'``: creates ROIs from a given atlas
  %    - ``'stats'``: runs model specification / estimation, contrast computation, display results
  %    - ``'contrasts'``: runs contrast computation, display results
  %    - ``'results'``: displays results
  %
  % *Optional parameters common to all actions*
  %
  % :param participant_label: cell of participants labels.
  %                           For example: ``{'01', '03', '08'}``.
  %                           Can be a regular expression.
  %                           Defaults to ``{}``
  % :type participant_label:  cellstr
  %
  % :param task:              Defaults to ``{}``
  % :type  task:              cell string
  %
  % :param space:             Defaults to ``{}``
  % :type  space:             cell string
  %
  % :param bids_filter_file:  path to JSON file or structure
  % :type  bids_filter_file:  path
  %
  % :param verbosity:         can be any value between ``0`` and ``3``. Defaults to ``2``
  % :type  verbosity:         positive integer
  %
  % :param options:           See the ``checkOptions`` help to see the available options.
  % :type  options:           path to JSON file or structure
  %
  % .. note::
  %
  %   Arguments passed to bidspm have priorities over the options defined in ``opt``.
  %   For example passing the argument ``'dry_run', true``
  %   will override the option ``opt.dryRun =  false``.
  %
  %
  %
  % **PREPROCESSING**
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'preprocess', ...
  %           'participant_label', {}, ...
  %           'task', {}, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'options', struct([]), ...
  %           'boilerplate_only', false, ...
  %           'dry_run', false, ...
  %           'dummy_scans', 0, ...
  %           'anat_only', false, ...
  %           'ignore', {}, ...
  %           'fwhm', 6, ...
  %           'skip_validation', false)
  %
  %
  % *Extra parameters for preprocessing*
  %
  % :param boilerplate_only:  Only creates dataset description reports.
  %                           and methods description. Defaults to ``false``.
  % :type  boilerplate_only:  logical
  %
  % :param dry_run:           Defaults to ``false``
  % :type  dry_run:           logical
  %
  % :param dummy_scans:       Number of dummy scans to remove. Defaults to ``0``.
  % :type  dummy_scans:       positive scalar
  %
  % :param anat_only:         Only preprocesses anatomical data. Defaults to ``false``.
  % :type  anat_only:         logical
  %
  % :param ignore:            can be any of ``{'fieldmaps', 'slicetiming', 'unwarp', 'qa'}``
  % :type  ignore:            cell string
  %
  % :param fwhm:              Smoothing to apply to the preprocessed data. Defaults to ``6``.
  % :type  fwhm:              positive scalar
  %
  % :param skip_validation:   To skip bids dataset or bids stats model validation.
  %                           Defaults to ``false``.
  % :type  skip_validation:   logical
  %
  %
  %
  % **COPY**
  %
  % Copies and unzips input data to output dir.
  % For example for fmriprep data before smoothing.
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'copy', ...
  %           'participant_label', {}, ...
  %           'task', {}, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'options', struct([]), ...
  %           'anat_only', false, ...
  %           'force', false)
  %
  %
  % *Extra parameters for copy*
  %
  % :param force:      Overwrites previous data if true. Defaults to ``false``.
  % :type  force:      logical
  %
  % :param anat_only:  Only copies anatomical data. Defaults to ``false``.
  % :type  anat_only:  logical
  %
  %
  %
  % **CREATE_ROI**
  %
  % Creates ROIs from a given atlas.
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'create_roi', ...
  %           'participant_label', {}, ...
  %           'space', {'MNI'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'options', struct([]), ...
  %           'roi_atlas', 'wang', ...
  %           'roi_name', {'V1v', 'V1d'}, ...
  %           'hemisphere', {'L', 'R'})
  %
  % :param roi_atlas:     Can be any of:
  %                       - ``'visfatlas'``
  %                       - ``'anatomy_toobox'``
  %                       - ``'neuromorphometrics'``
  %                       - ``'hcpex'``
  %                       - ``'wang'``
  %                       - ``'glasser'``
  %                       Defaults to ``'neuromorphometrics'``
  % :type  roi_atlas:     char
  %
  % :param roi_name:      Name of the roi to create. If the ROI does not exist in the atlas,
  %                       the list of available ROI will be returned in the error message.
  % :type  roi_name:      cell string
  %
  % :param hemisphere:    Hemisphere of the ROI to create.
  %                       Not all ROIs have both hemispheres.
  %                       Defaults to ``{'L', 'R'}``.
  % :type  hemisphere:    cell string containing any of 'L', 'R'
  %
  %
  %
  % **SMOOTH:**
  %
  % Copies files to output dir and smooths them.
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'smooth', ...
  %           'participant_label', {}, ...
  %           'task', {}, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'options', struct([]), ...
  %           'verbosity', 2, ...
  %           'fwhm', 6, ...
  %           'dry_run', false)
  %
  % :param fwhm:       Smoothing to apply to the preprocessed data. Defaults to ``6``.
  % :type  fwhm:       positive scalar
  %
  % :param dry_run:    Defaults to ``false``.
  % :type  dry_run:    logical
  %
  % :param anat_only:  Only smooths the anatomical data. Defaults to ``false``.
  % :type  anat_only:  logical
  %
  %
  %
  % **CREATE DEFAULT_MODEL**
  %
  % Creates a default BIDS stats model for a given raw BIDS dataset.
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'dataset', ...
  %           'action', 'default_model', ...
  %           'participant_label', {}, ...
  %           'task', {}, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'options', struct([]), ...
  %           'ignore', {})
  %
  %
  % :param ignore:      can be any of ``{'contrasts', 'transformations', 'dataset'}``
  % :type  ignore:      cell string
  %
  %
  %
  % **STATS**
  %
  % .. note::
  %
  %   - ``'stats'``     runs model specification / estimation, contrast computation, display results
  %   - ``'contrasts'`` runs contrast computation, display results
  %   - ``'results'``   displays results
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'stats', ...
  %           'participant_label', {}, ...
  %           'task', {}, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'bids_filter_file', struct([]), ...
  %           'options', struct([]), ...,
  %           'verbosity', 2, ...
  %           'preproc_dir', preproc_dir, ...        % specific to stats
  %           'model_file', model_file, ...          % specific to stats
  %           'fwhm', 6, ...
  %           'dry_run', false, ...
  %           'boilerplate_only', false, ...
  %           'roi_atlas', 'neuromorphometrics', ...
  %           'roi_based', false, ...
  %           'roi_dir', '', ...
  %           'roi_name', {''}, ...
  %           'design_only', false, ...
  %           'ignore', {}, ...
  %           'concatenate', false, ...
  %           'skip_validation', false)
  %
  %
  % *Obligatory parameters*
  %
  % :param preproc_dir: path to preprocessed data
  % :type  preproc_dir: path
  %
  % :param model_file:
  % :type  model_file:  path to JSON file or structure
  %
  %
  % *Optional parameters*
  %
  % :param fwhm:          smoothing lelvel of the preprocessed data
  % :type  fwhm:          positive scalar
  %
  % :param design_only:   to only run the model specification when at the group level
  % :type  design_only:   logical
  %
  % :param ignore:        can be any of ``{'qa'}``, to skip
  %                       quality controls or contanetation of beta images
  %                       into a single 4D image.
  % :type  ignore:        cell string
  %
  % :param concatenate:   will contatenate the beta images of the
  %                       conditions of interest convolved by an HRF.
  % :type  concatenate:   logical
  %
  % :param dry_run:       Defaults to ``false``.
  % :type  dry_run:       logical
  %
  % :param roi_atlas:     Name of the atlas to use to label activations in MNI space.
  % :type  roi_atlas:     char
  %
  % :param roi_based:
  % :type  roi_based:     logical
  %
  % :param roi_dir:
  % :type  roi_dir:       path
  %
  % :param roi_name:
  % :type  roi_name:      cell string
  %
  % :param boilerplate_only:  Only creates dataset description reports.
  %                           and methods description. Defaults to ``false``.
  % :type  boilerplate_only:  logical
  %
  %
  %
  % **low level calls**
  %
  % USAGE:
  %
  % .. code-block:: matlab
  %
  %   % initialise (add relevant folders to path)
  %   bidspm
  %
  %   % equivalent to
  %   bidspm init
  %   bidspm('action', 'init')
  %
  %   % help
  %   bidspm help
  %   bidspm('action', 'help')
  %
  %   % uninitialise (remove relevant folders from path)
  %   bidspm uninit
  %   bidspm('action', 'uninit')
  %
  %   % also adds folder for testing to the path
  %   bidspm dev
  %   bidspm('action', 'dev')
  %
  %   % tried to update the current branch from the upstream repository
  %   bidspm update
  %   bidspm('action', 'update')
  %
  %   % misc
  %   bidspm version
  %   bidspm('action', 'version')
  %
  %   bidspm run_tests
  %   bidspm('action', 'run_tests')
  %
  %
  % For a more readable version of this help section,
  % see the online <a
  % href="https://bidspm.readthedocs.io/en/latest/usage_notes.html">documentation</a>.
  %

  % (C) Copyright 2022 bidspm developers
