#!/bin/bash

read -p "Enter beaconfuzz_v2 folder with crashes (e.g: hfuzz_workspace/diff_attestation): " ARTIFACT_FOLDER

echo "Enter container type- [possible values: Attestation, AttesterSlashing, Block, BlockHeader, Deposit, ProposerSlashing, VoluntaryExit]"
read -p "input: " CONTAINER_TYPE

. ./env

echo "container type: $CONTAINER_TYPE"

#BEACONFUZZ_V2_BASE="/tmp/fuzzing/beacon-fuzz/beaconfuzz_v2"
BEACONFUZZ_V2_BASE="/Users/parithosh/dev/ansible/ansible-beaconfuzz-runner"

echo "Number of crash files to test: $(ls -l $BEACONFUZZ_V2_BASE/$ARTIFACT_FOLDER | grep -v ^l | wc -l) "
NUMBER_OF_FALSE_POSITIVES=0
NUMBER_OF_ACTUAL_CRASHES=0
FAILURE_ARRAY=("")

for filename in "$BEACONFUZZ_V2_BASE"/"$ARTIFACT_FOLDER"/*; do
  echo "testing $filename"
  FALSE_COUNTER=0

  # Runs the beaconfuzz debug tool inside a docker container
  FALSE_COUNTER=$( docker run -v "$BEACONFUZZ_V2_BASE"/"$ARTIFACT_FOLDER":"$BEACONFUZZ_V2_BASE"/"$ARTIFACT_FOLDER"  parithoshj/beaconfuzz_v2:latest ./beaconfuzz_v2 debug beacon.ssz "$filename" "$CONTAINER_TYPE" | grep -c "false")

  if [ "$(( FALSE_COUNTER % 2))" -ne 0 ]; then
        echo "Only 1 false detected!"
        NUMBER_OF_ACTUAL_CRASHES=$((NUMBER_OF_ACTUAL_CRASHES + 1))
        FAILURE_ARRAY+=("$filename")
  else
        echo "Unable to recreate error"
        NUMBER_OF_FALSE_POSITIVES=$((NUMBER_OF_FALSE_POSITIVES + 1))
  fi
done

echo "********************************************"
echo "Deleting unused docker containers (a ton would have been created by this script)"
echo "********************************************"

docker system prune

echo "Number of false positives: $NUMBER_OF_FALSE_POSITIVES"
echo "Number of actual recreated crashes: $NUMBER_OF_ACTUAL_CRASHES"
echo "Please re-confirm that all the files are accounted for (add up the numbers)."
