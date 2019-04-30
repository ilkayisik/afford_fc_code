#!/bin/bash
# Resting State Preprocessing and Group ICA with Dual Regression
root=/Users/ilkay.isik/project_folder_temp/fc_content/MRI_data/lscp_data/derivatives
cd $root

# Parameters
sm_sigma=2.548 #spatial smoothing at 6mm FWHM, specified in mm
scale_mean=10000
hp_sigma=50 # 200s / TR / 2 # highpass at 0.005 hz # can try different cut offs here later
echo $hp_sigma
lp_sigma=-1 #NONE old: #10s / TR / 2

# subject for loop
for subj in {02..25}; do
  echo "Subject $subj"
  mkdir analysis/sub-${subj}
  mkdir analysis/sub-${subj}/rest
  #rest_scan=fmriprep/sub-${subj}/func/sub-${subj}_task-rest_run-01_bold_space-MNI152NLin2009cAsym_preproc.nii.gz
  rest_scan=fmriprep/sub-${subj}/func/sub-${subj}_task-rest_run-01_bold_space-MNI152NLin2009cAsym_variant-smoothAROMAnonaggr_preproc.nii.gz
  brain_mask=fmriprep/sub-${subj}/func/sub-${subj}_task-rest_run-01_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz
  echo $rest_scan
  echo $brain_mask

  # Masking for brain extraction
  bet=_bet
  rest_bet=${rest_scan%%.nii.gz}$bet.nii.gz
  echo "Brain Exraction: $rest_bet"
  fslmaths $rest_scan -mas $brain_mask $rest_bet

  # Clean the data first with fsl_regfilt?

  # Applying spatial smoothing
  ss=_ss
  rest_ss=${rest_bet%%.nii.gz}$ss.nii.gz
  echo "Spatial Smoothing: $rest_ss"
  fslmaths $rest_bet -kernel gauss $sm_sigma -fmean $rest_ss

  # Applying intensity normalization
  in=_inorm
  rest_ss_inorm=${rest_ss%%.nii.gz}$in.nii.gz
  echo "Intensity Normalization: $rest_ss_inorm"
  fslmaths $rest_ss -ing $scale_mean $rest_ss_inorm -odt float

  # applying Filtering
  fslmaths $rest_ss_inorm -Tmean ${rest_ss_inorm%%.nii.gz}$m.nii.gz
  flt=_hpf
  rest_ss_inorm_flt=${rest_ss_inorm%%.nii.gz}$flt.nii.gz
  echo "Bandpass Filtering: $rest_ss_inorm_flt"
  fslmaths $rest_ss_inorm -bptf $hp_sigma $lp_sigma -add ${rest_ss_inorm%%.nii.gz}$m.nii.gz $rest_ss_inorm_flt

  # carry files to another directory
  mv $rest_bet analysis/sub-${subj}/rest
  mv $rest_ss analysis/sub-${subj}/rest
  mv $rest_ss_inorm analysis/sub-${subj}/rest
  mv $rest_ss_inorm_flt analysis/sub-${subj}/rest
  rm ${rest_ss_inorm%%.nii.gz}$m.nii.gz
done

folder_name=groupICA_20comp_26Sub
# Run group ICA
melodic -i analysis/groupICA/gica_input_files.txt \
-o analysis/groupICA/${folder_name} \
--tr=2 --nobet -a concat \
--bgthreshold=10 \
--report --Oall -d 20

# dual regression
dual_regression analysis/groupICA/${folder_name}/melodic_IC 1 \
analysis/groupICA/design/design.mat \
analysis/groupICA/design/design.con 1000 \
analysis/groupICA/${folder_name}/groupICA_20comp.dr \
`cat analysis/groupICA/gica_input_files.txt`
