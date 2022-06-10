clean:
	rm -rf dummyData/derivatives/cpp_spm-preproc/sub-*
	rm -rf dummyData/derivatives/cpp_spm-stats/sub-*
	rm -rf dummyData/cpp_spm-raw/sub-*
	rm -rf dummyData/derivatives/cpp_spm-stats/group
	rm -rf dummyData/derivatives/cpp_spm-*/jobs
	rm -rf bids-examples
	mkdir bids-examples && touch bids-examples/.gitkeep

data: clean
	sh createDummyDataSet.sh
	rm -rf bids-examples/
	git clone https://github.com/bids-standard/bids-examples.git --depth 1
	cp bids-examples/synthetic/dataset_description.json bids-examples/synthetic/derivatives/fmriprep
	touch bids-examples/.gitkeep

clean_openneuro:
	rm -rf openneuro/*

openneuro/ds001168/sub-01/ses-2/anat:
	mkdir openneuro -p
	datalad clone https://github.com/OpenNeuroDatasets/ds001168.git openneuro/ds001168
	cd openneuro/ds001168 && datalad get sub-01/ses-1/anat/* sub-01/ses-*/func/*fullbrain*
