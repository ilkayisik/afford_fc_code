#!/bin/bash
for subj in {01..05}; do
    echo $subj
    heudiconv \
    -d /Users/ilkay.isik/Desktop/afford_analysis_test/dicom/{subject}/*dcm \
    -o /Users/ilkay.isik/Desktop/afford_analysis_test/nifti/sub-$subj \
    -f /Users/ilkay.isik/Desktop/afford_analysis_test/afford_heuristic.py \
    -c dcm2niix \
    -s $subj -b
done
