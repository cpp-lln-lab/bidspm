function opt = getSubjectList(BIDS, opt)
  %
  % Returns the subjects to analyze in ``opt.subjects``
  %
  % USAGE::
  %
  %   opt = getSubjectList(BIDS, opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param BIDSdir: the directory where the data is ; default is :
  %                 ``fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm')``
  % :type BIDSdir: string
  %
  % :returns:
  %           - :opt: (structure)
  %
  % To set set the groups of subjects to analyze::
  %
  %     opt.groups = {'control', 'blind'};
  %
  % If there are no groups (i.e subjects names are of the form ``sub-01`` for
  % example) or if you want to run all subjects of all groups then use::
  %
  %   opt.groups = {''};
  %   opt.subjects = {[]};
  %
  % If you have more than 2 groups but want to only run the subjects of 2
  % groups then you can use::
  %
  %     opt.groups = {'cont', 'cat'};
  %     opt.subjects = {[], []};
  %
  % You can also directly specify the subject label for the participants you
  % want to run::
  %
  %     opt.groups = {''};
  %     opt.subjects = {'01', 'cont01', 'cat02', 'ctrl02', 'blind01'};
  %
  % (C) Copyright 2021 CPP_SPM developers

  allSubjects = bids.query(BIDS, 'subjects');

  % Whatever subject entered must be returned "linearized"
  tmp = opt.subjects;
  tmp = tmp(:);

  % if any group is mentioned
  if ~isempty(opt.groups{1}) && ...
          any(strcmpi({'group'}, fieldnames(BIDS.participants.content)))

    fields = fieldnames(BIDS.participants.content);
    fieldIdx = strcmpi({'group'}, fields);

    subjectIdx = strcmp(BIDS.participants.content.(fields{fieldIdx}), opt.groups);

    subjects = char(BIDS.participants.content.participant_id);
    subjects = cellstr(subjects(subjectIdx, 5:end));

    tmp = cat(1, tmp, subjects);

  end

  % If no subject specified so far we take all subjects
  if isempty(tmp) || iscell(tmp) && isempty(tmp{1})
    tmp = allSubjects;
  end

  % remove duplicates
  opt.subjects = unique(tmp);

  if size(opt.subjects, 1) == 1
    opt.subjects = opt.subjects';
  end

  % check that all the subjects asked for exist
  if any(~ismember(opt.subjects, allSubjects))
    fprintf('subjects specified\n');
    disp(opt.subjects);
    fprintf('subjects present\n');
    disp(allSubjects);

    errorStruct.identifier = 'getSubjectList:noMatchingSubject';
    errorStruct.message = 'Some of the subjects specified do not exist in this data set.';
    error(errorStruct);
  end

end
