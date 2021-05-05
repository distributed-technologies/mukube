#!/bin/bash
DIR=$1
HELM_REQUIREMENTS=$2
mkdir $DIR -p
cat $HELM_REQUIREMENTS | grep -w ".*http.*"   | while read p; do
  echo $p
  url=$(echo $p | cut -f1 -d' ')
  release=$(echo $p | cut -f2 -d' ')
  namespace=$(echo $p | cut -f3 -d' ')
  filename=$(echo $url | rev | cut -f1 -d/ | rev)
  # Download and rename file to include release and namespace
  $(wget -O "$DIR/$release#$namespace#$filename" $url)
done

numberOfFiles=$(ls $DIR | wc -l)
linesInFile=$(grep -w ".*http.*" -c $HELM_REQUIREMENTS)

if [ $numberOfFiles != $linesInFile ]; then
    echo "[error] Helm charts download failed. 
          Numer of files in $DIR:$numberOfFiles does not equal the lines in helm requirements:$linesInFile"
    exit 1
fi
