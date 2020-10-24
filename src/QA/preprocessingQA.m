% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function preprocessingQA(opt)
    % preprocessingQA(opt)
    
    % if input has no opt, load the opt.mat file
    if nargin < 1
        opt = [];
    end
    opt = loadAndCheckOptions(opt);
    
    flags = setFlags(opt);
    
    [group, opt, BIDS] = getData(opt);
    
    fprintf(1, 'DOING PREPROCESSING\n');
    
    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)
        
        groupName = group(iGroup).name;
        
        for iSub = 1:group(iGroup).numSub
            
            subID = group(iGroup).subNumber{iSub};
            
            printProcessingSubject(groupName, iSub, subID);
            
            fprintf(1, ' ANATOMICAL: QUALITY CONTROL\n');
            
%             [avgDistToSurf] = doAnatQA(BIDS, subID, opt);
            
            fprintf(1, ' ANATOMICAL: RESLICE TPM TO FUNCTIONAL\n');
            [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subID, opt);
            
            [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);
            grayTPM = validationInputFile(anatDataDir, anatImage, 'c1');
            whiteTPM = validationInputFile(anatDataDir, anatImage, 'c2');
            csfTPM = validationInputFile(anatDataDir, anatImage, 'c3');
            
            matlabbatch = setBatchReslice(...
                fullfile(meanFuncDir, meanImage), ...
                {grayTPM; whiteTPM; csfTPM});
            
            saveMatlabBatch(matlabbatch, 'reslice_tpm', opt, subID);
            spm_jobman('run', matlabbatch);
            
            fprintf(1, ' FUNCTIONAL: QUALITY CONTROL\n');
            % For functional data, QA is consists in getting temporal SNR and then
            % check for motion - here we also compute additional regressors to
            % account for motion
            
            grayTPM = validationInputFile(anatDataDir, anatImage, 'rc1');
            whiteTPM = validationInputFile(anatDataDir, anatImage, 'rc2');
            csfTPM = validationInputFile(anatDataDir, anatImage, 'rc3');
            
            [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');
            
            for iSes = 1:nbSessions
                
                % get all runs for that subject across all sessions
                [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});
                
                for iRun = 1:nbRuns
                    
                    % get the filename for this bold run for this task
                    [fileName, subFuncDataDir] = getBoldFilename( ...
                        BIDS, ...
                        subID, ...
                        sessions{iSes}, ...
                        runs{iRun}, ...
                        opt);
                    
                    prefix = getPrefix('smoothing_space-individual', opt);
                    funcImage = validationInputFile(subFuncDataDir, fileName, prefix);
                    
                    % sanity check that all images are in the same space.
                    volumesToCheck = {funcImage; grayTPM; whiteTPM; csfTPM};
                    spm_check_orientations(spm_vol(char(volumesToCheck)));
                    
                    
                    drawFigure = true;
                    fMRIQA.tSNR(1, iRun) = spmup_temporalSNR(...
                        funcImage, ...
                        {grayTPM; whiteTPM; csfTPM}, ...
                        drawFigure);
                    
                    %                     tmp = spmup_first_level_qa(...
                    %                         NormalizedAnat_file, ...
                    %                         cell2mat(stats_ready(frun)), ...
                    %                         flags);
                    %                     fMRIQA.meanFD(1, frun) = mean( spmup_FD(cell2mat(tmp), davg) );
                    %                     clear tmp;
                    %
                    %                     QA.tSNR = fMRIQA.tSNR(1, frun);
                    %                     QA.meanFD = fMRIQA.meanFD(1, frun);
                    %
                    %                     save([fileparts(Normalized_files{frun}) filesep 'fMRIQA.mat'], 'QA', '-v7');
                    %                     clear QA;
                    
                end
                
            end
            
            
            %             [filepath,filename,ext] = fileparts(subjects{s}.anat);
            %             EPI_class{1} = [filepath filesep 'c1r' filename ext];
            %             EPI_class{2} = [filepath filesep 'c2r' filename ext];
            %             EPI_class{3} = [filepath filesep 'c3r' filename ext];
            %
            %             % create carpet plots
            %             for frun = 1:size(subjects{s}.func, 1)
            %                 if bold_include(frun)
            %
            %                     fprintf('subject %g: fMRI Quality control: carpet plot \n', s);
            %
            %                     P = subjects{s}.func{frun};
            %                     c1 = EPI_class{1};
            %                     c2 = EPI_class{2};
            %                     c3 = EPI_class{3};
            %
            %                     spmup_timeseriesplot(P, c1, c2, c3, ...
            %                         'motion', 'on', ...
            %                         'nuisances', 'on', ...
            %                         'correlation', 'on');
            %
            %                 end
            %             end
            
        end
    end
    
end


function [avgDistToSurf] = doAnatQA(BIDS, subID, opt)
    
    [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);
    
    grayMatterTPM = validationInputFile(anatDataDir, anatImage, 'c1');
    whiteMatterTPM = validationInputFile(anatDataDir, anatImage, 'c2');
    
    % sanity check that all images are in the same space.
    anatImage = fullfile(anatDataDir, anatImage);
    volumesToCheck = {anatImage; grayMatterTPM; whiteMatterTPM};
    spm_check_orientations(spm_vol(char(volumesToCheck)));
    
    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    anatQA = spmup_anatQA(anatImage, grayMatterTPM, whiteMatterTPM); %#ok<*NASGU>
    
    save(strrep(anatImage, '.nii', '_qa.mat'), 'anatQA', '-v7');
    
    avgDistToSurf = spmup_comp_dist2surf(anatImage);
    
end


function flags = setFlags(opt)
    
    flags = struct( ...
        'motion_parameters', 'off', ...
        'globals', 'off', ...
        'volume_distance', 'on', ...
        'movie', 'off', ...
        'AC', [], ...
        'average', 'on', ...
        'T1', 'on');
    
    if opt.scrubbing.do
        flags.motion_parameters = 'on';
        flags.volume_distance = 'off';
    end
    
end