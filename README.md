<!-- lint disable -->

**Code quality and style**

[![](https://img.shields.io/badge/Octave-CI-blue?logo=Octave&logoColor=white)](https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/actions)
![](https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/workflows/CI/badge.svg)

**Unit tests and coverage**

[![Build Status](https://travis-ci.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline.svg?branch=master)](https://travis-ci.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline)
[![codecov](https://codecov.io/gh/cpp-lln-lab/CPP_BIDS_SPM_pipeline/branch/master/graph/badge.svg)](https://codecov.io/gh/cpp-lln-lab/CPP_BIDS_SPM_pipeline)

**How to cite**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3556173.svg)](https://doi.org/10.5281/zenodo.3556173)

**Contributors**

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

<!-- lint enable -->

# CPPL SPM12 Pipeline

This is a set of functions to fMRI analysis on a
[BIDS data set](https://bids.neuroimaging.io/) using SPM12.

This can perform:

-   slice timing correction,

-   spatial preprocessing:

    -   realignment, coregistration `func` to `anat`, `anat` segmentation,
        normalization to MNI space

    -   realignm and unwarp, coregistration `func` to `anat`, `anat`
        segmentation

-   smoothing,

-   Quality analysis:

    -   for anatomical data
    -   for functional data

-   GLM at the subject level

-   GLM at the group level à la SPM (meaning using a summary statistics
    approach).

Please see our
[documentation](https://cpp-bids-spm.readthedocs.io/en/latest/index.html) for
more info.

The core functions are in the `src` folder.

## Installation

### Dependencies

Make sure that the following toolboxes are installed and added to the matlab
path.

For instructions see the following links:

<!-- lint disable -->

| Dependencies                                                                              | Used version |
| ----------------------------------------------------------------------------------------- | ------------ |
| [Matlab](https://www.mathworks.com/products/matlab.html)                                  | 20???        |
| or [octave](https://www.gnu.org/software/octave/)                                         | 4.?          |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)                                | v7487        |
| [Tools for NIfTI and ANALYZE image toolbox](https://github.com/sergivalverde/nifti_tools) | NA           |
| [spmup](https://github.com/CPernet/spmup)                                                 | NA           |

<!-- lint enable -->

## Contributors

Thanks goes to these wonderful people
([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- lint disable -->
<table>
  <tr>
    <td align="center"><a href="https://cpplab.be"><img src="https://avatars0.githubusercontent.com/u/55407947?v=4" width="100px;" alt="OliColli"/><br /><sub><b>OliColli</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=OliColli" title="Code">💻</a> <a href="#design-OliColli" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=OliColli" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/anege"><img src="https://avatars0.githubusercontent.com/u/50317099?v=4" width="100px;" alt="anege"/><br /><sub><b>anege</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=anege" title="Code">💻</a> <a href="#design-anege" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/mohmdrezk"><img src="https://avatars2.githubusercontent.com/u/9597815?v=4" width="100px;" alt="Mohamed Rezk"/><br /><sub><b>Mohamed Rezk</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=mohmdrezk" title="Code">💻</a> <a href="#review-mohmdrezk" title="Reviewed Pull Requests">👀</a> <a href="#design-mohmdrezk" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/marcobarilari"><img src="https://avatars3.githubusercontent.com/u/38101692?v=4" width="100px;" alt="marcobarilari"/><br /><sub><b>marcobarilari</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=marcobarilari" title="Code">💻</a> <a href="#design-marcobarilari" title="Design">🎨</a> <a href="#review-marcobarilari" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=marcobarilari" title="Documentation">📖</a></td>
    <td align="center"><a href="https://remi-gau.github.io/"><img src="https://avatars3.githubusercontent.com/u/6961185?v=4" width="100px;" alt="Remi Gau"/><br /><sub><b>Remi Gau</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=Remi-Gau" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=Remi-Gau" title="Documentation">📖</a> <a href="#infra-Remi-Gau" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#design-Remi-Gau" title="Design">🎨</a> <a href="#review-mohmdrezk" title="Reviewed Pull Requests">👀</a></td>
  </tr>
</table>
<!-- lint enable -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the
[all-contributors](https://github.com/all-contributors/all-contributors)
specification. Contributions of any kind welcome!
