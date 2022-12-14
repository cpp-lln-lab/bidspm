
opt.QA.anat.do = 1, ;
opt.QA.func.Basics = 'on'  ;
opt.QA.func.FD = 'on'  ;
opt.QA.func.Globals = 'on'  ;
opt.QA.func.Motion = 'on'  ;
opt.QA.func.Movie = 'off'  ;
opt.QA.func.Voltera = 'on'  ;
opt.QA.func.carpetPlot = 1, ;
opt.QA.func.do = 1, ;
opt.QA.glm.do = 0, ;
opt.anatOnly = 0, ;
opt.bidsFilterFile.bold.modality = 'func'  ;
opt.bidsFilterFile.bold.suffix = 'bold'  ;
opt.bidsFilterFile.fmap.modality = 'fmap'  ;
opt.bidsFilterFile.mp2rage.modality = 'anat'  ;
opt.bidsFilterFile.mp2rage.space = ''  ;
opt.bidsFilterFile.mp2rage.suffix = 'MP2RAGE'  ;
opt.bidsFilterFile.roi.modality = 'roi'  ;
opt.bidsFilterFile.roi.suffix = 'mask'  ;
opt.bidsFilterFile.t1w.modality = 'anat'  ;
opt.bidsFilterFile.t1w.space = ''  ;
opt.bidsFilterFile.t1w.suffix = 'T1w'  ;
opt.bidsFilterFile.t2w.modality = 'anat'  ;
opt.bidsFilterFile.t2w.suffix = 'T2w'  ;
opt.bidsFilterFile.xfm.modality = 'anat'  ;
opt.bidsFilterFile.xfm.suffix = 'xfm'  ;
opt.bidsFilterFile.xfm.to = 'T1w'  ;
opt.contrastList = {};
opt.dir.derivatives = 'derivatives'  ;
opt.dir.input = ''  ;
opt.dir.jobs = 'jobs'  ;
opt.dir.output = ''  ;
opt.dir.preproc = ''  ;
opt.dir.raw = ''  ;
opt.dir.stats = ''  ;
opt.dryRun = 0, ;
opt.funcVolToSelect = []  ;
opt.funcVoxelDims = []  ;
opt.fwhm.contrast = 0.000, ;
opt.fwhm.func = 6.000, ;
opt.glm.keepResiduals = 0, ;
opt.glm.maxNbVols = Inf, ;
opt.glm.roibased.do = 0, ;
opt.glm.useDummyRegressor = 0, ;
opt.groups{1} = ''  ;
opt.model.designOnly = 0, ;
opt.model.file = ''  ;
opt.msg.color = ''  ;
opt.pipeline.name = 'bidspm'  ;
opt.pipeline.type = ''  ;
opt.query.modality{1} = 'anat'  ;
opt.query.modality{2} = 'func'  ;
opt.realign.useUnwarp = 1, ;
opt.rename = 1, ;
opt.results.MC = 'FWE'  ;
opt.results.atlas = 'Neuromorphometrics'  ;
opt.results.binary = 0, ;
opt.results.csv = 1, ;
opt.results.k = 0.000, ;
opt.results.montage.background = '/home/remi/github/spm12/canonical/avg152T1.nii'  ;
opt.results.montage.do = 0, ;
opt.results.montage.orientation = 'axial'  ;
opt.results.montage.slices = []  ;
opt.results.name{1} = ''  ;
opt.results.nidm = 1, ;
opt.results.nodeName = ''  ;
opt.results.p = 0.050, ;
opt.results.png = 1, ;
opt.results.threshSpm = 0, ;
opt.results.useMask = 0, ;
opt.segment.biasfwhm = 60.000, ;
opt.segment.do = 1, ;
opt.segment.force = 0, ;
opt.segment.samplingDistance = 3.000, ;
opt.skullstrip.do = 1, ;
opt.skullstrip.force = 0, ;
opt.skullstrip.mean = 0, ;
opt.skullstrip.threshold = 0.750, ;
opt.space{1} = 'individual'  ;
opt.space{2} = 'IXI549Space'  ;
opt.stc.referenceSlice = []  ;
opt.stc.skip = 0, ;
opt.subjects{1} = []  ;
opt.tolerant = 1, ;
opt.toolbox.MACS.model.files = []  ;
opt.toolbox.rsHRF.vox_rsHRF.Denoising.BPF = {};
opt.toolbox.rsHRF.vox_rsHRF.Denoising.Despiking = 0.000, ;
opt.toolbox.rsHRF.vox_rsHRF.Denoising.Detrend = 0.000, ;
opt.toolbox.rsHRF.vox_rsHRF.Denoising.generic = {};
opt.toolbox.rsHRF.vox_rsHRF.Denoising.which1st = 3.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.cvi = 0.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.fmri_t = 1.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.fmri_t0 = 1.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.hrfdeconv = 1.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.hrflen = 32.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.hrfm = 2.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.localK = 2.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.mdelay = 4.000, 8.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.num_basis = NaN, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.thr = 1.000, ;
opt.toolbox.rsHRF.vox_rsHRF.HRFE.tmask = NaN, ;
opt.toolbox.rsHRF.vox_rsHRF.connectivity = {};
opt.toolbox.rsHRF.vox_rsHRF.prefix = 'deconv_'  ;
opt.toolbox.rsHRF.vox_rsHRF.rmoutlier = 0.000, ;
opt.toolbox.rsHRF.vox_rsHRF.savedata.deconv_save = 0.000, ;
opt.toolbox.rsHRF.vox_rsHRF.savedata.hrfmat_save = 1.000, ;
opt.toolbox.rsHRF.vox_rsHRF.savedata.hrfnii_save = 1.000, ;
opt.toolbox.rsHRF.vox_rsHRF.savedata.job_save = 0.000, ;
opt.useBidsSchema = 0, ;
opt.useFieldmaps = 1, ;
opt.verbosity = 2.000, ;
opt.zeropad = 2.000, ;
