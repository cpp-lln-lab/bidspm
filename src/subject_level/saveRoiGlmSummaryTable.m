function outputFile = saveRoiGlmSummaryTable(varargin)
  %
  % Creates a single table for a subject with all ROIs and conditions
  %
  % USAGE::
  %
  %   outputFile = saveRoiGlmSummaryTable(opt, subLabel, roiList, eventSpec)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % :param roiList: a cellstr of roi with bids friendly filenames
  % :type  roiList: cellstr
  %
  % :param eventSpec: "eventSpec(iCon).name"
  % :type  eventSpec: struct
  %
  %
  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  addRequired(args, 'opt');
  addRequired(args, 'subLabel');
  addRequired(args, 'roiList');
  addRequired(args, 'eventSpec');

  parse(args, varargin{:});

  opt = args.Results.opt;
  subLabel = args.Results.subLabel;
  roiList = args.Results.roiList;
  eventSpec = args.Results.eventSpec;

  checks(opt);

  outputDir = getFFXdir(subLabel, opt);

  %% make a list of the files to load
  dataToCompile = {};
  for iROI = 1:size(roiList, 1)

    nameStructure = roiGlmOutputName(opt, subLabel, roiList{iROI, 1});

    nameStructure.suffix = 'timecourse';
    nameStructure.ext = '.json';
    bidsFile = bids.File(nameStructure);
    dataToCompile{end + 1, 1} = fullfile(outputDir, bidsFile.filename);

  end

  %% load and extract the data
  psc = {'max', 'absMax'};
  row = 1;

  for i = 1:numel(dataToCompile)

    bidsFile = bids.File(dataToCompile{i});

    if ~exist(dataToCompile{i}, 'file')
      bf = bids.File(dataToCompile{i});
      msg = sprintf('No data file found for sub-%s / roi %s\n', ...
                    subLabel, ...
                    bf.entities.label);
      id = 'noRoiResultFileForRoi';
      errorHandling(mfilename(), id, msg, true, opt.verbosity);
      continue
    end

    jsonContent = bids.util.jsondecode(dataToCompile{i});

    for iCon = 1:numel(eventSpec)

      tsvContent.label{row} = bidsFile.entities.label;

      if isfield(bidsFile.entities, 'hemi')
        tsvContent.hemi{row} = bidsFile.entities.hemi;
      else
        tsvContent.hemi{row} = nan;
      end

      if isfield(bidsFile.entities, 'desc')
        tsvContent.desc{row} = bidsFile.entities.desc;
      else
        tsvContent.desc{row} = nan;
      end

      tsvContent.voxels(row) = jsonContent.size.voxels;
      tsvContent.volume(row) = jsonContent.size.volume;

      conName = eventSpec(iCon).name;
      tsvContent.contrast_name{row} = conName;

      for j = 1:numel(psc)
        if isfield(jsonContent, conName)
          value = jsonContent.(conName).percentSignalChange.(psc{j});
        else
          value = nan;
        end
        tsvContent.(['percent_signal_change_' psc{j}])(row) = value;
      end

      row = row + 1;

    end

  end

  if ~exist('tsvContent', 'var')
    msg = sprintf('No roi results found for sub-%s.\n', subLabel);
    id = 'noRoiResultsForSubject';
    errorHandling(mfilename(), id, msg, true, opt.verbosity);
    return
  end

  %% save
  bidsFile = bids.File(outputDir);
  bidsFile.suffix = 'summary';
  bidsFile.extension = '.tsv';

  outputFile = fullfile(outputDir, bidsFile.filename);

  bids.util.tsvwrite(outputFile, tsvContent);

end

function checks(opt)

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end

  if ~opt.glm.roibased.do
    msg = '"opt.glm.roibased.do" must be set to true for this workflow to to run.';
    id = 'roiBasedAnalysis';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);
  end

end
