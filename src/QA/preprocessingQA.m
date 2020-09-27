
function preprocessingQA(opt)
    % bidsSpatialPrepro(opt)
    %
    % Performs spatial preprocessing of the functional and structural data.
    % The structural data are segmented and normalized to MNI space.
    % The functional data are re-aligned, coregistered with the structural and
    % normalized to MNI space.
    %
    % The
    %
    % Assumptions:
    % - will take the first T1w images as reference
    % - assume the anatomical T1w to use for normalization is in the
    % first session
    % - the batch is build using dependencies across the different batch modules
    
    % TO DO
    % - find a way to paralelize this over subjects
    % - average T1s across sessions if necessarry
    
    % Indicate which session the structural data was collected
    structSession = 1;
    
    % if input has no opt, load the opt.mat file
    if nargin < 1
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end
    
    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);
    
    fprintf(1, 'DOING PREPROCESSING\n');
    
    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)
        
        groupName = group(iGroup).name;
        
        for iSub = 1:group(iGroup).numSub
            
            % Get the ID of the subject
            % (i.e SubNumber doesnt have to match the iSub if one subject
            % is exluded for any reason)
            subID = group(iGroup).subNumber{iSub}; % Get the subject ID
            
            printProcessingSubject(groupName, iSub, subID);
            
            % identify sessions for this subject
            sessions = getInfo(BIDS, subID, opt, 'Sessions');
            
            fprintf(1, ' ANATOMICAL: QUALITY CONTROL\n');
            % get all T1w images for that subject and
            anat = spm_BIDS(BIDS, 'data', ...
                'sub', subID, ...
                'ses', sessions{structSession}, ...
                'type', 'T1w');
            
            % we assume that the first T1w is the correct one (could be an
            % issue for dataset with more than one
            anat = anat{1};
            
            % sanity check that all images are in the same space.
            V_to_check = Normalized_class';
            V_to_check{end + 1} = NormalizedAnat_file;
            spm_check_orientations(spm_vol(char(V_to_check)));
            
            % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
            % This is useful to check coregistration and normalization worked fine
            tmp = spmup_anatQA(NormalizedAnat_file, Normalized_class{1}, Normalized_class{2});
            
            save([fileparts(NormalizedAnat_file) filesep 'anatQA.mat'], 'tmp');
            
            
            
            fprintf(1, ' FUNCTIONAL: QUALITY CONTROL\n');
            % For functional data, QA is consists in getting temporal SNR and then
            % check for motion - here we also compute additional regressors to
            % account for motion
            
            davg = spmup_comp_dist2surf(anat);
            
            if strcmpi(options.scrubbing, 'on')
                flags = struct( ...
                    'motion_parameters', 'on', ...
                    'globals', 'on', ...
                    'volume_distance', 'off', ...
                    'movie', 'off', ...
                    'AC', [], ...
                    'average', 'on', ...
                    'T1', 'on');
            else
                flags = struct( ...
                    'motion_parameters', 'off', ...
                    'globals', 'off', ...
                    'volume_distance', 'on', ...
                    'movie', 'off', ...
                    'AC', [], ...
                    'average', 'on', ...
                    'T1', 'on');
            end
            
            for frun = 1:size(stats_ready, 1)
                
                % sanity check that all images are in the same space.
                V_to_check = Normalized_class';
                V_to_check{end + 1} = stats_ready{frun};
                spm_check_orientations(spm_vol(char(V_to_check)));
                
                % fMRIQA.tSNR(1, frun) = spmup_temporalSNR(Normalized_files{frun}, Normalized_class, 1);
                fMRIQA.tSNR(1, frun) = spmup_temporalSNR(Normalized_files{frun}, Normalized_class, 0);
                
                tmp = spmup_first_level_qa(NormalizedAnat_file, cell2mat(stats_ready(frun)), flags);
                fMRIQA.meanFD(1, frun) = mean(spmup_FD(cell2mat(tmp), davg));
                clear tmp;
                
                QA.tSNR = fMRIQA.tSNR(1, frun);
                QA.meanFD = fMRIQA.meanFD(1, frun);
                
                save([fileparts(Normalized_files{frun}) filesep 'fMRIQA.mat'], 'QA');
                clear QA;
                
            end
            
            % create carpet plots
            for frun = 1:size(subjects{s}.func, 1)
                if bold_include(frun)
                    
                    fprintf('subject %g: fMRI Quality control: carpet plot \n', s);
                    P = subjects{s}.func{frun};
                    c1 = EPI_class{1};
                    c2 = EPI_class{2};
                    c3 = EPI_class{3};
                    spmup_timeseriesplot(P, c1, c2, c3, ...
                        'motion', 'on', ...
                        'nuisances', 'on', ...
                        'correlation', 'on');
                    
                end
            end

        end
    end
    
end