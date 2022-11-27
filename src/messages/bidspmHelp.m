function bidspmHelp()
  %
  % General intro function for bidspm
  %
  %
  % Note:
  %
  % - all parameters use ``snake_case``
  % - most "invalid" calls simply initialize bidspm
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
  %           'dry_run', false, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'options', struct([]), ...
  %           'skip_validation', false)
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
  % :param analysis_level:  can either be ``'subject'`` or ``'dataset'``
  % :type  analysis_level:  string
  %
  % :param action: defines the pipeline to run; can be any of:
  %
  %                - ``'copy'``: copies fmriprep data for smoothing
  %                - ``'preprocess'``
  %                - ``'smooth'``: smooths data
  %                - ``'default_model'``
  %                - ``'stats'``
  %                - ``'contrasts'``
  %                - ``'results'``
  % :type action: char
  %
  % .. note::
  %
  %   - ``'stats'``     runs model specification / estimation, contrast computation, display results
  %   - ``'contrasts'`` runs contrast computation, display results
  %   - ``'results'``   displays results
  %
  % *Optional parameters common to all actions*
  %
  % :param participant_label: cell of participants labels.
  %                           For example: ``{'01', '03', '08'}``.
  %                           Can be a regular expression.
  % :type participant_label:  cellstr
  %
  % :param dry_run:           Defaults to ``false``
  % :type dry_run:            logical
  %
  % :param bids_filter_file:  path to JSON file or structure
  % :type  bids_filter_file:  path
  %
  % :param verbosity:         can be ``0``, ``1`` or ``2``. Defaults to ``2``
  % :type  verbosity:         positive integer
  %
  % :param space:             Defaults to ``{'individual', 'IXI549Space'}``
  % :type  space:             cell string
  %
  % :param options:           See the ``checkOptions`` help to see the available options.
  % :type  options:           path to JSON file or structure
  %
  % :param skip_validation:   To skip bids dataset or bids stats model validation.
  % :type  skip_validation:   logical
  %
  % .. note::
  %
  %   Arguments passed to bidspm have priorities over the options defined in ``opt``.
  %   For example passing the argument ``'dry_run', true``
  %   will override the option ``opt.dryRun =  false``.
  %
  %
  % **PREPROCESSING:**
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'preprocess', ...
  %           'participant_label', {}, ...
  %           'dry_run', false, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'options', struct([]), ...
  %           'task', {}, ...
  %           'dummy_scans', 0, ...       % specific to preprocessing
  %           'anat_only', false, ...     % specific to preprocessing
  %           'ignore', {}, ...
  %           'fwhm', 6, ...
  %           'skip_validation', false)
  %
  %
  % *Obligatory parameters*
  %
  % .. TODO check if REALLY obligatory
  %
  % :param task:        only one task
  % :type  task:        cell string
  %
  % :param dummy_scans: Number of dummy scans to remove. Defaults to ``0``
  % :type  dummy_scans:  positive scalar
  %
  %
  % *Optional parameters*
  %
  % :param anat_only:
  % :type  anat_only:   logical
  %
  % :param ignore:      can be any of ``{'fieldmaps', 'slicetiming', 'unwarp', 'qa'}``
  % :type  ignore:      cell string
  %
  % :param fwhm:        smoothing to apply to the preprocessed data
  % :type  fwhm:        positive scalar
  %
  %
  % **COPY:**
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'copy', ...
  %           'participant_label', {}, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'options', struct([]), ...
  %           'task', {}, ...
  %           'skip_validation', false)
  %
  %
  % **SMOOTH:**
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'smooth', ...
  %           'participant_label', {}, ...
  %           'dry_run', false, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'options', struct([]), ...
  %           'task', {}, ...
  %           'fwhm', 6, ...
  %           'skip_validation', false)
  %
  %
  % **DEFAULT_MODEL:**
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'dataset', ...
  %           'action', 'default_model', ...
  %           'verbosity', 2, ...
  %           'space', {'IXI549Space'}, ...
  %           'options', struct([]), ...,
  %           'task', {})
  %
  %
  % **STATS:**
  %
  % .. code-block:: matlab
  %
  %   bidspm(bids_dir, output_dir, 'subject', ...
  %           'action', 'stats', ...
  %           'preproc_dir', preproc_dir, ...        % specific to stats
  %           'model_file', model_file, ...          % specific to stats
  %           'participant_label', {}, ...
  %           'dry_run', false, ...
  %           'bids_filter_file', struct([]), ...
  %           'verbosity', 2, ...
  %           'space', {'individual', 'IXI549Space'}, ...
  %           'options', struct([]), ...,
  %           'roi_based', false, ...
  %           'design_only', false, ...
  %           'ignore', {}, ...
  %           'concatenate', false, ...
  %           'task', {}, ...
  %           'fwhm', 6, ...
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
  % :param roi_based:
  % :type  roi_based:     logical
  %
  % :param task:
  % :type  task:          cell string
  %
  % :param fwhm:          smoothing lelvel of the preprocessed data
  % :type  fwhm:          positive scalar
  %
  % :param design_only:   to only run the model specification when at the group level
  % :type  design_only:   logical
  %
  % :param ignore:        can be any of ``{'qa', 'concat'}``, to skip
  %                       quality controls or contanetation of beta images
  %                       into a single 4D image.
  % :type  ignore:        cell string
  %
  % :param concatenate:   will contatenate the beta images of the
  %                       conditions of interest convolved by an HRF.
  % :type  concatenate:   logical
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
  %  For a more readable version of this help section,
  %  see the online <a
  %  href="https://bidspm.readthedocs.io/en/latest/usage_notes.html">documentation</a>.
  %

  % (C) Copyright 2022 bidspm developers
