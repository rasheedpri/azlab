#!/bin/bash
fileid="1nf9CPWz6cWiFbsbOerhmBEK5sF_QfOC9"
filename="fgt.vhd"
curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${filename}