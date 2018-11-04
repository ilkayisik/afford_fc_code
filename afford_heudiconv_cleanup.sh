#!/bin/bash
# to delete the unnecessary files created by heudiconv
root='/Users/ilkay.isik/project_folder_temp/fc_content/MRI_data/data_BIDS/Nifti/'
cd $root
rm sub-*/func/*pfobloc_run-01_events.tsv
cp sub-01/sub-01_task-pfobloc_run-01_events.tsv sub-*/func/sub-01_task-pfobloc_run-01_events.tsv
rm sub-*/CHANGES
rm sub-*/README
rm -R sub-*/sourcedata
rm sub-*/dataset_description.json
rm sub-*/*json

# rm sub-*/anat/*.json
# rm sub-*/func/*.json

# copy the participants.tsv file from the 1st subject dir to one folder above
# and run below command which will copy the content from other subjects tsv's
for subj in {11..26}; do
  echo $subj
  tail -1 sub-$subj/participants.tsv >> participants.tsv
done

# delete the single participants files:
rm sub-*/participants.tsv


# Get rid of the first 2 timepoints
rmtp=2
for subj in {03..10}; do
  echo $subj
  for fmap in $(ls sub-$subj/fmap/*epi.nii.gz); do
    echo $fmap
    fslroi $fmap $fmap $rmtp -1
  done

  for func in $(ls sub-$subj/func/*bold.nii.gz); do
    echo $func
    fslroi $func $func $rmtp -1
  done
done

# put the files back to nii.gz
for subj in {01..10}; do
  echo $subj
  echo sub-$subj/fmap/*.nii.gz
  rm sub-$subj/fmap/*.nii.gz
  gzip sub-$subj/fmap/*.nii

  echo sub-$subj/func/*.nii.gz
  rm sub-$subj/func/*.nii.gz
  gzip sub-$subj/func/*.nii
done

# how many files are in fmap folder for each subject?
for subj in {01..26}; do
  echo $subj
  ls -1q sub-$subj/fmap/*.nii.gz | wc -l
  for fname in $(ls sub-$subj/fmap/*.nii.gz); do
    echo $fname
  done
done





# To modify the fmap json files: # add total readout time, change phase enc dir,
# intended for values with the right bold scan name
root=/Users/ilkay.isik/project_folder_temp/fc_content/MRI_data/BIDS/Nifti
cd $root
for sub in {01..26}; do
  echo $sub
  tsv_file=$(ls sub-$sub/*_scans.tsv) # where the bold info comes from
  echo $tsv_file
  for jfname in $(ls sub-$sub/fmap/*.json); do
    echo $jfname
    fmap_name=${jfname:23:9} #PA_run-01
    echo $fmap_name
    # extract the bold scan comes right after the fmap
    bold_name=$(grep -A1 "$fmap_name" $tsv_file|grep -v "$fmap_name"|sed 's/2018.*//')
    echo $bold_name
    bold_name=${bold_name::-1}
    echo $bold_name
    # write this value back to the fmap .json file
    tempfile=$(mktemp -u)
    jq '.PhaseEncodingDirection="j"' $jfname > "$tempfile"
    mv "$tempfile" "$jfname"

    tempfile=$(mktemp -u)
    jq '.TotalReadoutTime=0.035'  $jfname > "$tempfile"
    mv "$tempfile" "$jfname"

    tempfile=$(mktemp -u)
    jq --arg bold "$bold_name" '.IntendedFor=$bold' $jfname > "$tempfile"
    mv "$tempfile" "$jfname"
  done # end jfname
done # end sub




## not using this anymore because the better way is done and working!!!

# modify the json files for the fmaps
# easier but not good method: need to make sure the fmap is really intended for that run
# copy sub-01's json files from fmap to other subjects fmap folders and rename them
root=/Users/ilkay.isik/project_folder_temp/fc_content/MRI_data/BIDS/Nifti
for subj in {02..10}; do
  echo $subj
  rm sub-$subj/fmap/*.json
  cp sub-01/fmap/*.json sub-$subj/fmap/
  cd sub-$subj/fmap
  rename "s/01/$subj/" *.json
  cd $root
done

# change the value of subject number in intended for key in the json file
for sub in {02..10}; do
  echo $sub
  for jsonfile in $(ls sub-$sub/fmap/*.json); do
     echo $jsonfile
     tempfile=$(mktemp -u)
     jq --arg sub "$sub" '.IntendedFor|=(.|sub("(?<=sub-)[^_]+";$sub))' "$jsonfile" > "$tempfile"
     mv "$tempfile" "$jsonfile"
  done
done


# put the pfob task onset file to every subj bids dir
for sub in {02..26}; do
  echo $sub
  cp sub-01/func/sub-01_task-pfobloc_run-01_events.tsv sub-${sub}/func/sub-${sub}_task-pfobloc_run-01_events.tsv
done

# copy the tsv file for video run from sub 01's folder to the othet subs folder
for sub in {02..26}; do
  echo $sub
  run=1
  for tsvfile in $(ls sub-01/func/*video_run*events.tsv); do
    echo sub-${sub}/func/sub-${sub}_task-video_run-0${run}_events.tsv
    cp $tsvfile sub-${sub}/func/sub-${sub}_task-video_run-0${run}_events.tsv
    run=$((run+1))
  done
done
