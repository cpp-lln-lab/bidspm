% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function [maxProbaFiles, roiLabels] = getRetinoProbaAtlas()
  %
  % Loads the volumetric data from the
  % Probabilistic Maps of Visual Topography in Human Cortex
  %
  % maxProbaVol: 4D volume of ROIs in MNII space with
  %
  %              - left hemisphere as maxProbaVol(:,:,:,1)
  %              - right hemisphere as maxProbaVol(:,:,:,2)
  %
  %   DOI 10.1093/cercor/bhu277
  %   PMCID: PMC4585523
  %   PMID: 25452571
  %   Probabilistic Maps of Visual Topography in Human Cortex
  %
  % If the data is not present in the ``cpp_spm/atlas/ProbAtlas_v4`` of the repo, it will be
  % downloaded and unzipped

  README_URL = 'http://scholar.princeton.edu/sites/default/files/napl/files/readme.txt';
  ATLAS_URL = 'http://scholar.princeton.edu/sites/default/files/napl/files/probatlas_v4.zip';

  ATLAS_FOLDER = fullfile( ...
                          fileparts(mfilename('fullpath')), ...
                          '..', '..',  'atlas');

  if ~exist(fullfile(ATLAS_FOLDER, 'ProbAtlas_v4'), 'dir')

    mkdir(ATLAS_FOLDER);

    try
      urlwrite(ATLAS_URL, 'probatlas_v4.zip');
      unzip('probatlas_v4.zip', ATLAS_FOLDER);
    catch
      system(sprintf('curl -L %s -o probatlas_v4.zip', ATLAS_URL));
      unzip('probatlas_v4.zip', ATLAS_FOLDER);
    end

  end

  %     urlwrite(README_URL, fullfile(ATLAS_FOLDER, 'ProbAtlas_v4', 'README.txt'));
  %     urlread(README_URL)

  maxProbaFiles = spm_select('FPListRec', ...
                             fullfile(ATLAS_FOLDER, 'ProbAtlas_v4'), ...
                             '^max.*.nii$');

  if size(maxProbaFiles, 1) < 2

    gunzip(fullfile(pwd, 'atlas', 'ProbAtlas_v4', 'subj_vol_all', 'max*.nii.gz'));

    maxProbaFiles = spm_select('FPListRec', ...
                               fullfile(ATLAS_FOLDER, 'ProbAtlas_v4'), ...
                               '^max.*.nii$');

  end

  if size(maxProbaFiles, 1) < 2
    error('no atlas present');
  end

  % the label file was created manually to be easier to load into SPM
  roiLabels = spm_load(spm_select('FPListRec', ...
                                  fullfile(ATLAS_FOLDER), ...
                                  '^ROI_labels_ProbAtlas_v4.csv$'));

end
