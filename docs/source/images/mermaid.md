graph TD

    CLI[bidspm]

    subgraph bidsResults

    B1(setBatchSubjectLevelResults) --> |01, opt\n loop over Contrast| B2_01(setBatchResults)
    B1(setBatchSubjectLevelResults) --> |02, opt\n loop over Contrast| B2_02(setBatchResults)

    B2_01(setBatchResults) --> batch_01{{matlabbatch_01}}
    B2_02(setBatchResults) --> batch_02{{matlabbatch_02}}

    batch_01 --> D1[[batch_compute_sub_01_*_level_results_*.m]]
    batch_02 --> D2[[batch_compute_sub_02_*_level_results_*.m]]

    batch_01 --> E[SPM12]
    batch_02 --> E[SPM12]
    end

    CLI -->|--action results\n--participant-label 01 02\n--model_file smdl.json| bidsResults
