<!-- markdown-link-check-disable -->

<!-- .. only:: html -->

[![Documentation Status: stable](https://readthedocs.org/projects/cpp_spm/badge/?version=stable)](https://cpp_spm.readthedocs.io/en/stable/?badge=stable)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/cpp-lln-lab/CPP_SPM/dev)
[![miss_hit](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/miss_hit.yml/badge.svg)](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/miss_hit.yml)
[![tests with octave](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/run_tests_octave.yml/badge.svg)](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/run_tests_octave.yml)
[![tests with matlab](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/run_tests_matlab.yml/badge.svg)](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/run_tests_matlab.yml)
[![system tests with matlab](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/run_system_tests_matlab.yml/badge.svg)](https://github.com/cpp-lln-lab/CPP_SPM/actions/workflows/run_system_tests_matlab.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![codecov](https://codecov.io/gh/cpp-lln-lab/CPP_SPM/branch/master/graph/badge.svg?token=8IoRQtbFUV)](https://codecov.io/gh/cpp-lln-lab/CPP_SPM)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3554331.svg)](https://doi.org/10.5281/zenodo.3554331)
[![All Contributors](https://img.shields.io/badge/all_contributors-10-orange.svg?style=flat-square)](https://github.com/cpp-lln-lab/CPP_SPM#contributors)

<!-- markdown-link-check-enable -->

# CPP SPM

This is a Matlab / Octave toolbox to perform MRI data analysis on a
[BIDS data set](https://bids.neuroimaging.io/) using SPM12.

## Installation and set up

```bash
git clone \
    --recurse-submodules \
    https://github.com/cpp-lln-lab/CPP_SPM.git
```

To get the latest version that is on the `dev` branch.

```bash
git clone \
    --recurse-submodules \
    --branch dev \
    https://github.com/cpp-lln-lab/CPP_SPM.git
```

To start using CPP_SPM, you just need to initialize it for this MATLAB / Octave
session with::

```matlab
cpp_spm()
```

Please see our
[documentation](https://cpp-spm.readthedocs.io/en/dev/general_information.html)
for more info.

## Usage

For some of its functionality cpp_spm has a BIDS app like API.

See
[this page for more information](https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html).

### Preprocessing

```matlab

bids_dir = path_to_raw_bids_dataset;
output_dir = path_to_where_the_output_should_go;

subject_label = '01';

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'preprocess', ...
        'task', {...})
```

### GLM

```matlab

bids_dir = path_to_raw_bids_dataset;
preproc_dir = path_to_preprocessed_dataset;
output_dir = path_to_where_the_output_should_go;
model_file = path_to_bids_stats_model_json_file;

subject_label = '01';

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file)
```

Please see our
[documentation](https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html) for
more info.

## Features

### Preprocessing

If your data is fairly "typical" (for example whole brain coverage functional
data with one associated anatomical scan for each subject), you might be better
off running [fmriprep](https://fmriprep.org/en/stable/) on your data.

If you have more exotic data that cannot be handled well by fmriprep then
CPP_SPM has some automated workflows to perform amongst other things:

-   remove dummies

-   slice timing correction

-   spatial preprocessing:

    -   realignment OR realignm and unwarp
    -   coregistration `func` to `anat`,
    -   `anat` segmentation and skull stripping
    -   (optional) normalization to SPM's MNI space

-   smoothing

-   fieldmaps processing and voxel displacement map creation (work in progress)

All (well almost all) preprocessed outputs are saved as BIDS derivatives with BIDS compliant
filenames.

### Statistics

The model specification are set up using the
[BIDS stats model](https://bids-standard.github.io/stats-models/) and can be
used to perform:

-   whole GLM at the subject level
-   whole brain GLM at the group level à la SPM (meaning using a summary
    statistics approach).
-   ROI based GLM (using marsbar)
-   model selection (with the MACS toolbox)

### Quality control:

-   anatomical data (work in progress)
-   functional data (work in progress)
-   GLM auto-correlation check

Please see our
[documentation](https://cpp_spm.readthedocs.io/en/latest/index.html) for more
info.

## Citation

```bibtex
@software{CPP_SPM,
  author  = {Gau, Rémi and Barilari, Marco and Battal, Ceren and Rezk, Mohamed and Collignon, Olivier and Gurtubay, Ane and Falagiarda, Federica and MacLean, Michèle and Cerpelloni, Filippo and Shahzad, Iqra and Nunes, Márcia},
  license = {GPL-3.0},
  title   = {CPP SPM},
  url     = {https://github.com/cpp-lln-lab/CPP_SPM},
  version = {1.1.5dev},
  doi     = {10.5281/zenodo.3554331},
  publisher = {Zenodo},
  journal = {Software}
}
```

## Contributors

Thanks goes to these wonderful people
([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/anege"><img src="https://avatars0.githubusercontent.com/u/50317099?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ane Gurtubay</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=anege" title="Code">💻</a> <a href="#design-anege" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/CerenB"><img src="https://avatars1.githubusercontent.com/u/10451654?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ceren Battal</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3ACerenB" title="Bug reports">🐛</a> <a href="#content-CerenB" title="Content">🖋</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=CerenB" title="Documentation">📖</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=CerenB" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3ACerenB" title="Reviewed Pull Requests">👀</a> <a href="#userTesting-CerenB" title="User Testing">📓</a></td>
    <td align="center"><a href="https://github.com/fedefalag"><img src="https://avatars2.githubusercontent.com/u/50373329?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Federica Falagiarda</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Afedefalag" title="Bug reports">🐛</a> <a href="#userTesting-fedefalag" title="User Testing">📓</a></td>
    <td align="center"><a href="https://github.com/fcerpe"><img src="https://avatars.githubusercontent.com/u/73432853?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Filippo Cerpelloni</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Afcerpe" title="Bug reports">🐛</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=fcerpe" title="Tests">⚠️</a> <a href="#userTesting-fcerpe" title="User Testing">📓</a></td>
    <td align="center"><a href="https://github.com/iqrashahzad14"><img src="https://avatars.githubusercontent.com/u/75671348?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Iqra Shahzad</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Aiqrashahzad14" title="Bug reports">🐛</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=iqrashahzad14" title="Documentation">📖</a> <a href="#question-iqrashahzad14" title="Answering Questions">💬</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3Aiqrashahzad14" title="Reviewed Pull Requests">👀</a> <a href="#userTesting-iqrashahzad14" title="User Testing">📓</a></td>
    <td align="center"><a href="https://github.com/marcobarilari"><img src="https://avatars3.githubusercontent.com/u/38101692?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Marco Barilari</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=marcobarilari" title="Code">💻</a> <a href="#design-marcobarilari" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3Amarcobarilari" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=marcobarilari" title="Documentation">📖</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=marcobarilari" title="Tests">⚠️</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Amarcobarilari" title="Bug reports">🐛</a> <a href="#userTesting-marcobarilari" title="User Testing">📓</a></td>
    <td align="center"><a href="https://github.com/mwmaclean"><img src="https://avatars.githubusercontent.com/u/54547865?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Michèle MacLean</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=mwmaclean" title="Code">💻</a> <a href="#ideas-mwmaclean" title="Ideas, Planning, & Feedback">🤔</a> <a href="#userTesting-mwmaclean" title="User Testing">📓</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/mohmdrezk"><img src="https://avatars2.githubusercontent.com/u/9597815?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mohamed Rezk</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=mohmdrezk" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3Amohmdrezk" title="Reviewed Pull Requests">👀</a> <a href="#design-mohmdrezk" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/mcgnunes"><img src="https://avatars.githubusercontent.com/u/98760858?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Márcia Nunes</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Amcgnunes" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://cpplab.be"><img src="https://avatars0.githubusercontent.com/u/55407947?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Olivier Collignon</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=OliColli" title="Code">💻</a> <a href="#design-OliColli" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=OliColli" title="Documentation">📖</a></td>
    <td align="center"><a href="https://remi-gau.github.io/"><img src="https://avatars3.githubusercontent.com/u/6961185?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Remi Gau</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=Remi-Gau" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=Remi-Gau" title="Documentation">📖</a> <a href="#infra-Remi-Gau" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#design-Remi-Gau" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3ARemi-Gau" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3ARemi-Gau" title="Bug reports">🐛</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=Remi-Gau" title="Tests">⚠️</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the
[all-contributors](https://github.com/all-contributors/all-contributors)
specification. Contributions of any kind welcome!
