#!/bin/bash
for subj in {01..02}; do
echo $subj
docker run -ti --rm \
     -v /Users/ilkay.isik/localApps/freesurfer/license.txt:/opt/freesurfer/license.txt:ro \
     -v /Users/ilkay.isik/Projects/afford_fc/mri_data/bids:/data:ro \
     -v /Users/ilkay.isik/Projects/afford_fc/mri_data/derivatives:/out \
     poldracklab/fmriprep:1.1.8 \
     /data /out/out \
     participant \
     --participant-label sub-$subj \
     --fs-no-reconall \
     --ignore slicetiming \
     --use-syn-sdc \
     --output-space T1w template \
     --use-aroma \
     --write-graph \
     --nthreads 2 --n_cpus 3 --mem_mb 28000 \
done
