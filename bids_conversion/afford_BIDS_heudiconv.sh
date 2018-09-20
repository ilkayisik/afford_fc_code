#!/bin/bash
for subj in {1..5}; do
    echo $subj
    heudiconv \
    -d /Users/ilkay.isik/Desktop/afford_analysis_test/dicom/{subject}/*dcm\
    -s $subj \
    -c dcm2niix \
    -o /Users/ilkay.isik/Desktop/afford_analysis_test/nifti/ \
    -f /Users/ilkay.isik/Desktop/afford_analysis_test/afford_heuristic.py \
    -b
done
