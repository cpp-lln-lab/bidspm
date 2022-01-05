# Segmentation MP2RAGE

## NighRes

It does not work (at list on mine) on a mac, either using docker or the `build` installation.

## Freesurfer

useful links:

- https://surfer.nmr.mgh.harvard.edu/fswiki/SubmillimeterRecon
- https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all#ExpertOptionsFile
- https://surfer.nmr.mgh.harvard.edu/fswiki/HighFieldRecon
- https://layerfmri.com/2017/12/21/bias-field-correction/
- https://www.sciencedirect.com/science/article/abs/pii/S1053811905001102?via%3Dihub

`recon-all -all -s $SUBJECT -hires -i $IMAGE -expert $EXPERT_FILE`

content of the file `experts.opts` is `mris_inflate -n 100`

### Trials

- [ ] run it without bias field correction

#### trial 1

command run

```
recon-all -all -s pilot001_no-bias-co_mp2rage -hires -i sub-pilot001_ses-001_acq-hires_UNIT1.nii -expert /Users/barilari/Desktop/data_temp/Marco_HighRes/temp/expert.opts
```

failed:

from the logfile

```

lta_convert --src orig_nu.mgz --trg /Applications/freesurfer/mni/bin/../share/mni_autoreg/average_305.mnc --inxfm transforms/talairach.auto.xfm --outlta transforms/talairach.auto.xfm.lta --subject fsaverage


Sun Nov 28 16:37:39 CET 2021
talairach done
\n cp transforms/talairach.auto.xfm transforms/talairach.xfm \n
lta_convert --src orig.mgz --trg /Applications/freesurfer/average/mni305.cor.mgz --inxfm transforms/talairach.xfm --outlta transforms/talairach.xfm.lta --subject fsaverage --ltavox2vox
7.2.0

--src: orig.mgz src image (geometry).
--trg: /Applications/freesurfer/average/mni305.cor.mgz trg image (geometry).
--inmni: transforms/talairach.xfm input MNI/XFM transform.
--outlta: transforms/talairach.xfm.lta output LTA.
--s: fsaverage subject name
--ltavox2vox: output LTA as VOX_TO_VOX transform.
 LTA read, type : 1
 0.82282   0.13043  -0.16265  -16.83919;
-0.15668   0.69440  -0.23581  -62.39896;
 0.10661   0.28472   0.76759   87.35477;
 0.00000   0.00000   0.00000   1.00000;
setting subject to fsaverage
Writing  LTA to file transforms/talairach.xfm.lta...
lta_convert successful.
#--------------------------------------------
#@# Talairach Failure Detection Sun Nov 28 16:37:42 CET 2021
/Applications/freesurfer/subjects/pilot001_no-bias-co_mp2rage/mri
\n talairach_afd -T 0.005 -xfm transforms/talairach.xfm \n
ERROR: talairach_afd: Talairach Transform: transforms/talairach.xfm ***FAILED*** (p=0.0744, pval=0.0034 < threshold=0.0050)
\nManual Talairach alignment may be necessary, or
include the -notal-check flag to skip this test,
making sure the -notal-check flag follows -all
or -autorecon1 in the command string.
See:\n
http://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/Talairach

\nERROR: Talairach failed!\n
Darwin mac-554-749.local 18.7.0 Darwin Kernel Version 18.7.0: Tue Jun 22 19:37:08 PDT 2021; root:xnu-4903.278.70~1/RELEASE_X86_64 x86_64

recon-all -s pilot001_no-bias-co_mp2rage exited with ERRORS at Sun Nov 28 16:37:43 CET 2021

To report a problem, see http://surfer.nmr.mgh.harvard.edu/fswiki/BugReporting

```

This link is suggested above
https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/Talairach


#### trial 2

command run

```
recon-all -all -notal-check -s /Users/barilari/Desktop/data_temp/Marco_HighRes/temp/pilot001_no-bias-co_mp2rage -hires -i sub-pilot001_ses-001_acq-hires_UNIT1.nii -expert /Users/barilari/Desktop/data_temp/Marco_HighRes/temp/expert.opts
```


- [ ] run it with bias field correction
