# Conversions between tsv <--> matrix #

## convert_mat2tsv: ##
This script will take an SPM onset file that has 3 variables:
- names: [dimensions: 1 x number of conditions]
- onsets: in TR units [dimensions: 1 x number of conditions]
- durations: in TR units [dimensions: 1 x number of conditions]

The output of the script will be a tsv file with all conditions where onsets and durations will be in seconds.

## convert_tsv2mat: ##
This script will take a tsv file (unit of time is seconds) and convert it to an SPM onset file that has 3 variables:
- names: [dimensions: 1 x number of conditions]
- onsets: in TR units [dimensions: 1 x number of conditions]
- durations: in TR units [dimensions: 1 x number of conditions]

The output of the script will be an ONSET mat file that will be used by SPM in the FFX analysis. The onsets and durations will be in TR units. <br /><br />

_Attached one tsv and one onset.mat example files that you can experiment with._
