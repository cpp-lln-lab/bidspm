function opt = getSubjectList(BIDS, opt)
  %
  % Returns the subjects to analyze in ``opt.subjects``
  %
  % USAGE::
  %
  %   opt = getSubjectList(BIDS, opt)
  %
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData.
  % :type BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt:  structure
  %
  % :returns:
  %           - :opt: (structure)
  %
  %
  % If no group or subject is specified in ``opt`` then all subjects are included.
  % This is equivalent to the default::
  %
  %   opt.groups = {''};
  %   opt.subjects = {[]};
  %
  % If you want to run the analysis of some subjects only based on the group they
  % belong to **as defined in the ``participants.tsv``** file, you can do it like this::
  %
  %     opt.groups = {'control'};
  %
  % This will run the pipeline on all the ``control`` subjects.
  %
  % If your subject label is ``blnd02`` (as in ``sub-blnd02``) but its group affiliation
  % in the ``participants.tsv`` says ``control``, then this subject will NOT be included
  % if you run the pipeline with ``opt.groups = {'blnd'}``.
  %
  % If you have more than 2 groups you can specify them like this::
  %
  %     opt.groups = {'cont', 'cat'};
  %
  % You can also directly specify the subject label for the participants you
  % want to run::
  %
  %     opt.subjects = {'01', 'cont01', 'cat02', 'ctrl02', 'blind01'};
  %
  % And you can combine both methods::
  %
  %   opt.groups = {'blind'};
  %   opt.subjects = {'ctrl01'};
  %
  % This will include all ``blind`` subjects and ``sub-ctrl01``.
  %

  % (C) Copyright 2021 bidspm developers

  allSubjects = bids.query(BIDS, 'subjects');

  % Whatever subject entered must be returned "linearized"
  if ischar(opt.subjects)
    opt.subjects = {opt.subjects};
  end
  tmp = opt.subjects;
  tmp = tmp(:);

  % if any group is mentioned
  if ~isempty(opt.groups{1}) && ...
          any(strcmpi({'group'}, fieldnames(BIDS.participants.content)))

    participantsContent = BIDS.participants.content;

    fields = fieldnames(participantsContent);
    fieldIdx = strcmpi({'group'}, fields);

    subjectIdx = strcmp(participantsContent.(fields{fieldIdx}), opt.groups);

    subjects = char(participantsContent.participant_id);

    subjects = cellstr(subjects(subjectIdx, 5:end));

    tmp = cat(1, tmp, subjects);

  end

  % If no subject specified so far we take all subjects
  if isempty(tmp) || iscell(tmp) && isempty(tmp{1})
    tmp = allSubjects;
  end

  % remove duplicates
  opt.subjects = unique(tmp);

  % If one subject only we use regex
  if numel(opt.subjects) == 1
    tokens = regexp(allSubjects, opt.subjects, 'match');
    subjectPresent = ~cellfun('isempty', tokens);

    if ~any(subjectPresent)
      errorMissingSubject(opt, allSubjects);
    else
      opt.subjects = allSubjects(subjectPresent);
    end

  else
    % check that all the subjects asked for exist
    anySubjectMissing = any(~ismember(opt.subjects, allSubjects));

    if anySubjectMissing
      errorMissingSubject(opt, allSubjects);
    end

  end

  if size(opt.subjects, 1) == 1
    opt.subjects = opt.subjects';
  end

end

function errorMissingSubject(opt, allSubjects)
  subjectsSpecified = bids.internal.create_unordered_list(opt.subjects);
  subjectsPresent = bids.internal.create_unordered_list(allSubjects);

  msg = sprintf(['Some of the subjects specified do not exist in this data set.\n', ...
                 'subjects specified:%s \nsubjects present:%s'], ...
                subjectsSpecified, ...
                subjectsPresent);
  id = 'noMatchingSubject';
  logger('ERROR', msg, 'id', id, 'filename', mfilename());
end

function option = prepareRegex(option)
  option = option{1};
  if strcmp(option, '')
    return
  end
  if ~strcmp(option(1), '^')
    option = ['^' option];
  end
  if ~strcmp(option(end), '$')
    option = [option '$'];
  end
end
