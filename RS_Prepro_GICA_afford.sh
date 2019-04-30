#!/bin/bash
# Resting State Preprocessing and Group ICA with Dual Regression

root=/Users/ilkay.isik/Projects/afford_fc/mri_data/derivatives
cd $root

# Parameters
scale_mean=10000
hp_sigma=50 # 200s / TR / 2 # highpass at 0.005 hz # can try different cut offs here later
echo $hp_sigma
lp_sigma=-1 #NONE old: #10s / TR / 2

# subject for loop
for subj in 01 02 03 04 05 06 07 08 09 10 12 13 14 15 16 17 18 20 21 22 23 24 25 \
  26 27 29 30 31 32 34 35 36 37 38 39 40 41  ; do
  echo "Sub-$subj"
  mkdir analysis/sub-${subj}
  mkdir analysis/sub-${subj}/rest
  rest_scan=fmriprep/sub-${subj}/func/sub-${subj}_task-rest_run-01_bold_space-MNI152NLin2009cAsym_variant-smoothAROMAnonaggr_preproc.nii.gz
  echo $rest_scan

  # Applying intensity normalization - APPLYING NO INTENSITY NORM.
  #in=_inorm
  #rest_ss_inorm=${rest_scan%%.nii.gz}$in.nii.gz
  #echo "Intensity Normalization: $rest_ss_inorm"
  #fslmaths $rest_scan -ing $scale_mean $rest_ss_inorm -odt float

  # applying Filtering
  m=_mean
  fslmaths $rest_scan -Tmean ${rest_scan%%.nii.gz}$m.nii.gz
  flt=_hpf
  rest_scan_flt=${rest_scan%%.nii.gz}$flt.nii.gz
  echo "Bandpass Filtering: $rest_scan_flt"
  fslmaths $rest_scan -bptf $hp_sigma $lp_sigma -add ${rest_scan%%.nii.gz}$m.nii.gz $rest_scan_flt

  # carry files to another directory
  # mv $rest_ss_inorm analysis/sub-${subj}/rest
  mv $rest_scan_flt analysis/sub-${subj}/rest
  rm ${rest_scan%%.nii.gz}$m.nii.gz
done


folder_name=groupICA_30comp_AllSub_smoothVariant
input_files=gica_input_files_sm_variant.txt
# Run group ICA
melodic -i analysis/groupICA/$input_files \
-o analysis/groupICA/${folder_name} \
--tr=2 -a concat \
--bgthreshold=10 \
--report --Oall -d 30

# dual regression
dual_regression analysis/groupICA/${folder_name}/melodic_IC 1 \
analysis/groupICA/design/unpaired_ttest.mat \
analysis/groupICA/design/unpaired_ttest.con 5000 \
analysis/groupICA/${folder_name}/groupICA_30comp.dr \
`cat analysis/groupICA/gica_input_files_sm_variant.txt`


#To view the results from the dual regression analysis, run:
comp_nr=13
fsleyes analysis/groupICA/${folder_name}/mean.nii.gz \
analysis/groupICA/${folder_name}/melodic_IC -un -cm red-yellow -nc blue-lightblue -dr 4 15 \
analysis/groupICA/${folder_name}/groupICA_30comp.dr/dr_stage3_ic00${comp_nr}_tfce_corrp_tstat1.nii.gz \
-cm red -dr 0.95 1 \
analysis/groupICA/${folder_name}/groupICA_30comp.dr/dr_stage3_ic00${comp_nr}_tfce_corrp_tstat2.nii.gz \
-cm blue -dr 0.95 1 \
analysis/groupICA/${folder_name}/groupICA_30comp.dr/dr_stage3_ic00${comp_nr}_tfce_corrp_tstat3.nii.gz \
-cm green -dr 0.95 1 \
analysis/groupICA/${folder_name}/groupICA_30comp.dr/dr_stage3_ic00${comp_nr}_tfce_corrp_tstat4.nii.gz \
-cm yellow -dr 0.95 1 &
