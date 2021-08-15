clean:
	rm -rf dummyData/derivatives/cpp_spm-preproc/sub-*
	rm -rf dummyData/derivatives/cpp_spm-stats/sub-*
	rm -rf dummyData/derivatives/cpp_spm-stats/group
	rm -rf dummyData/derivatives/cpp_spm-*/jobs

data:
	sh createDummyDataSet.sh
	git clone git://github.com/bids-standard/bids-examples.git --depth 1
