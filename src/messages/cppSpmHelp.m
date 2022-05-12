function cppSpmHelp()
  %
  % General intro function for CPP SPM
  %
  %
  % Note:
  %
  % - all parameters use snake_case
  % - most invalid calls simply initialize CPP SPM
  %
  %
  %
  % **bids apps calls**
  %
  % generic call:
  %
  % .. code-block:: matlab
  %
  %   cpp_spm(bids_dir, output_dir, analysis_level, ...
  %           'action', 'some_action')
  %
  %
  % *Obligatory parameters*
  %
  % :param bids_dir: path to a raw BIDS dataset
  % :type bids_dir: path
  %
  % :param output_dir: path where to output data
  % :type output_dir: path
  %
  % :param analysis_level: can either be ``'participants'`` or ``'group'``
  % :type analysis_level: string
  %
  %
  % :param action: defines the pipeline to run; can be any of:
  %
  %                - ``'preprocess'``
  %                - ``'stats'``
  % :type action: string
  %
  %
  % *Optional parameters common to all actions*
  %
  % :param participant_label: cell of participants labels.
  %                           For example: ``{'01', '03', '08'}``
  % :type cellstr:
  %
  % :param dry_run: Defaults to ``false``
  % :type dry_run: logical
  %
  % :param bids_filter_file:
  % :type bids_filter_file: path to JSON file or structure
  %
  % :param options:
  % :type options: path to JSON file or structure
  %
  % :param verbosity: can be ``0``, ``1`` or ``2``. Defaults to ``2``
  % :type verbosity: positive scalar
  %
  % :param space: Defaults to ``{'individual', 'IXI549Space'}``
  % :type space: cell string
  %
  %
  % PREPROCESSING:
  %
  % .. code-block:: matlab
  %
  %   cpp_spm(bids_dir, output_dir, 'participant', ...
  %           'action', 'preprocess', ...
  %           'task', {...})
  %
  %
  % *Obligatory parameters*
  %
  % :param task: only one task
  % :type task: cell string
  %
  % :param dummy_scans: Number of dummy scans to remove. Defaults to ``0``
  % :type dummy_scans: positive scalar
  %
  %
  % *Optional parameters*
  %
  % :param anat_only:
  % :type anat_only: logical
  %
  % :param ignore: can be any of ``{'fieldmaps', 'slicetiming', 'unwarp'}``
  % :type ignore:  cell string
  %
  % :param fwhm: smoothing to apply to the preprocessed data
  % :type fwhm: positive scalar
  %
  %
  % STATS:
  %
  % .. code-block:: matlab
  %
  %   cpp_spm(bids_dir, output_dir, 'participant', ...
  %           'action', 'preprocess', ...
  %           'preproc_dir', preproc_dir, ...
  %           'model_file', model_file)
  %
  %
  % *Obligatory parameters*
  %
  % :param preproc_dir: path to preprocessed data
  % :type preproc_dir: path
  %
  % :param model_file:
  % :type model_file: path to JSON file or structure
  %
  %
  % *Optional parameters*
  %
  % :param roi_based:
  % :type roi_based: logical
  %
  % :param task:
  % :type task: cell string
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
  %   cpp_spm
  %
  %   % equivalent to
  %   cpp_spm('action', 'init')
  %
  %   % uninitialise (remove relevant folders from path)
  %   cpp_spm('action', 'uninit')
  %
  %   % also adds folder for testing to the path
  %   cpp_spm('action', 'dev')
  %
  %   % tried to update the current branch from the upstream repository
  %   cpp_spm('action', 'update')
  %
  %   % misc
  %   cpp_spm('action', 'version')
  %   cpp_spm('action', 'run_tests')
  %
  %
  % (C) Copyright 2022 CPP_SPM developers
