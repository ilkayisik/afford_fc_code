#!/bin/bash
for subj in {34..41}; do
    echo $subj
    heudiconv \
    -d /Users/ilkay.isik/Projects/afford_fc/mri_data/dcms/{subject}/*dcm \
    -o /Users/ilkay.isik/Projects/afford_fc/mri_data/bids/sub-$subj \
    -f /Users/ilkay.isik/Projects/afford_fc/afford_fc_code/bids_conversion/afford_heuristic.py \
    -c dcm2niix \
    -s $subj -b
done
