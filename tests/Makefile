clean: clean_local
	rm -rf bids-examples
	mkdir bids-examples && touch bids-examples/.gitkeep

clean_local:
	rm -rf data/derivatives/bidspm-preproc/sub-*
	rm -rf data/derivatives/bidspm-stats/sub-*
	rm -rf data/bidspm-raw/sub-*
	rm -rf data/derivatives/bidspm-stats/group
	rm -rf data/derivatives/bidspm-*/jobs

create_dummy_dataset: clean_local
	python create_dummy_dataset.py
	python create_3_groups_dataset.py

bids_examples:
	rm -rf bids-examples/
	git clone https://github.com/bids-standard/bids-examples.git --depth 1
	cp bids-examples/synthetic/dataset_description.json bids-examples/synthetic/derivatives/fmriprep
	touch bids-examples/.gitkeep

data: clean create_dummy_dataset bids_examples
	wget --quiet -O moae_spm12.zip https://files.de-1.osf.io/v1/resources/3vufp/providers/osfstorage/62ab741be6f3ec09a7e48d13/?zip=
	mkdir -p data/MoAE/derivatives/spm12
	unzip -d ./data/MoAE/derivatives/spm12 moae_spm12.zip

clean_openneuro:
	rm -rf openneuro/*

openneuro/ds001168/sub-01/ses-2/anat:
	mkdir openneuro -p
	datalad clone https://github.com/OpenNeuroDatasets/ds001168.git openneuro/ds001168
	cd openneuro/ds001168 && datalad get sub-01/ses-1/anat/* sub-01/ses-*/func/*fullbrain*
