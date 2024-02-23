###################################
SUBJECTID=UR14
PROJECT=speech-long-TCI
ROOT=~/sigurd/$PROJECT
####################################

mkdir -p $ROOT/data/ECoG-EDF/$SUBJECTID
mkdir -p $ROOT/$SUBJECTID
cp /archive/dmi/ecog-raw-data/$SUBJECTID/"$SUBJECTID"_TaskLog.xlsx $ROOT/$SUBJECTID
echo "look at $ROOT/"$SUBJECTID"_TaskLog.xlsx to figure out the session number"
cp /archive/dmi/ecog-raw-data/SummaryTaskLog.xlsx $ROOT
mkdir -p $ROOT/data/subjects-v1/$SUBJECTID # create directory to put experiment files
cp -r /archive/dmi/ecog-raw-data/$SUBJECTID/experiment-files/$PROJECT/* $ROOT/data/subjects-v1/$SUBJECTID/ # copy over all files

#figure out session NUMBERS according to "$SUBJECTID"_TaskLog.xlsx
##################################
NUMBERS=(5 9) # Define an array with the numbers
##################################


for NUMBER in "${NUMBERS[@]}"; do
    cp /archive/dmi/ecog-raw-data/$SUBJECTID/iEEG/sess$NUMBER.edf $ROOT/data/ECoG-EDF/$SUBJECTID/sess$NUMBER.edf
    cp /archive/dmi/ecog-raw-data/$SUBJECTID/session-notes/sess$NUMBER.docx $ROOT/$SUBJECTID
    echo "look at $ROOT/$SUBJECTID/sess$NUMBER.docx to figure out the trigger channel and audio channel which should be assigned inside the script."
    # copy sess_example script to working directory
    cp /scratch/snormanh_lab/shared/code/Automatic_preprocess/sess_example.m $ROOT/$SUBJECTID/sess$NUMBER.m

done



##################################
echo "look at $ROOT/data/subjects-v1/$SUBJECTID/timing-*.txt to figure out what stim_info mat file and which block should be used."