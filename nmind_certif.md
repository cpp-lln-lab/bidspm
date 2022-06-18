- [Bronze Certification](#bronze-certification)
    - [Documentation](#documentation)
    - [Infrastructure](#infrastructure)
    - [Testing](#testing)
- [Silver Certification](#silver-certification)
    - [Intended audience](#intended-audience)
    - [Documentation](#documentation-1)
    - [Infrastructure](#infrastructure-1)
    - [Testing](#testing-1)
- [Gold Certification](#gold-certification)
    - [Intended audience](#intended-audience-1)
    - [Documentation](#documentation-2)
    - [Infrastructure](#infrastructure-2)
    - [Testing](#testing-2)

## Bronze Certification

### Documentation

-   [x] Landing page (e.g., GitHub README, website) provides a link to
        documentation and brief description of what program does
-   [x] Documentation is up to date with version of software
-   [x] Typical intended usage is described
-   [x] An example of its usage is shown
-   [x] Document functions intended to be used by users (public function
        docstring / help coverage ≥ 10%)
-   [x] Description of required input parameters for user-facing functions with
        reasonable description of inputs (i.e. "Nifti of brain mask in MNI" vs.
        "An image file")
-   [ ] Description of output(s)
-   [x] User installation instructions available
-   [x] Dependencies listed (external and within-language requirements)

### Infrastructure

-   [x] Code is open source
-   [x] Package is under version control
-   [x] Readme is present
-   [x] License is present
-   [x] Issues tracking is enabled (either through GitHub or external site)
-   [x] Digital Object Identifier (DOI) points to latest version (e.g., Zenodo)
-   [x] All documented installation instructions can be successfully followed

### Testing

Some of these can be enforced by GitHub.

-   [x] Provide / generate / point to test data
-   [ ] Provide instructions for users to run tests that include instructions
        for evaluation for correct behavior

## Silver Certification

-   [ ] **All items from Bronze**

### Intended audience

-   users

### Documentation

-   [ ] Background/significance of program
-   [x] One or more tutorial to showcase the multiple of the program's usages
        (if program has multiple usages)
-   [ ] Any alternative usage that is advertised is thoroughly documented
-   [x] Thorough description of required and optional input parameters
-   [x] Document public functions (docstring / help coverage ≥ 20%)
-   [ ] A statement of supported operating systems / environments

### Infrastructure

-   [x] Issue template(s) available (information requested by developers)
-   [x] Continuous integration runs tests
-   [x] No excessive files included. (unused files / cached) (gitignore)

### Testing

-   [x] Some form of testing suite present (e.g., unit testing, integration
        testing, smoke tests)
-   [x] Test coverage > 50%

## Gold Certification

-   [ ] **All items from Silver**

### Intended audience

-   users
-   developers

### Documentation

-   [x] Continuous integration badges in README for
    -   [x] build status
    -   [x] tests passing
    -   [x] test coverage
    -   [x] style coverage
    -   [ ] docstring coverage
-   [x] Document functions, classes, modules, etc. (public + private docstring /
        help coverage ≥ 40%)
-   [x] Has a documented style guide
-   [ ] Maintenance status is documented (e.g., expected turnaround time on pull
        requests, whether project is maintained)

### Infrastructure

-   [x] Continuous integration
    -   [x] runs tests and builds packages
    -   [x] validates against style guide
-   [ ] Journal of Open Source Software submission
-   [x] Contribution guide present
-   [x] Code of Conduct present

### Testing

-   [ ] Test coverage > 90%
-   [ ] Benchmarking information is provided for examples (TODO: define
        information)
