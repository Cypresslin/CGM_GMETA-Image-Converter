#!/bin/bash
##############################################################
# CGM/GMETA Image Converter    Copyright (C) 2012 Cypresslin #
#         This script is distributed under GNU GPLv2.        #
# Visit http://cypresslin.web.fc2.com/ for more information. #
#                                                            #
# Usage: bash CGMConverter.sh YOUR_CGM.cgm                   #
##############################################################

#===== User Modification Area =====
 INcgm="$1"
 OPDir="./Output/"
 OUTprefix="CASEName-"
 OUTformat=".png"                     # png recommended
 ctransArg="-d ps.color"
 convertArg="-trim -density 300"
#===== End of User Modification =====
#
TmpFN="Temp-"                    # Temp file prefix
#----- Checking User-Defined Variables -----
OPDir=${OPDir%"/"}"/"            # Add a "/" after the output directory variable
OUTformat="."${OUTformat#"."}    # Add a "." before the output format variable
#----- Checking necessary tools -----
type ctrans >/dev/null 2>&1 || { echo >&2 "cmd: ctrans not found, NCARGraphics required."; exit 1; }
type med >/dev/null 2>&1 || { echo >&2 "cmd: convert not found, NCARGrphics required."; exit 1; }
type ncgmstat >/dev/null 2>&1 || { echo >&2 "cmd: ncgmstat not found, NCARGraphics required."; exit 1; }
type convert >/dev/null 2>&1 || { echo >&2 "cmd: convert not found, ImageMagick required."; exit 1; }

#----- Checking Existence -----
[ -f $INcgm ] || { echo -e "\033[1;31mInput File Does Not Exist!\033[m"; exit 1; }
#InputFileOK
Frames=`ncgmstat -c $INcgm`
echo -e "File: \033[1;33m$INcgm\033[m , with \033[1;33m$Frames\033[m frames"
if [ -d $OPDir ]; then
    #OutputDirOK
    echo -e "Output File goes to \033[1;33m$OPDir\033[m"
else
    echo "Output DIR Does Not Exist"
    read -p "Creat it Now? (y/n): " MKDIR
    if [ $MKDIR = "y" -o $MKDIR = "Y" ]; then
        echo -en "mkdir $OPDir : \033[1;31m"
        mkdir $OPDir 2>&1 || { echo -e >&2 "\033[m"; exit 1; }
        echo -e "\033[1;33mDONE\033[m"
    else
        echo -e "\033[1;31mProgram Terminated\033[m"
        exit 0
    fi
fi
#===== Generates *.ncgm =====
echo -ne "File Splitting...(${INcgm#*.} > .ncgm) \033[1;31m"
med -e "read $INcgm" -e "split $Frames $OPDir$TmpFN"
if [ $? != 0 ]; then
    echo -e "Splitting FAILED \033[m"
    exit 0
else
    echo -e "\033[33mDONE\033[m"
fi
echo "Format Converting... ncgm > ps > $OUTformat"
i=0
while [ $i -lt $Frames ]
do
    let "i = $i + 1"
    TmpFile=`printf $OPDir$TmpFN%03d.ncgm $i`
    OutTmp=`printf $OUTprefix%03d$OUTformat $i`
    ctrans $TmpFile $ctransArg >TEMP.ps  
    convert TEMP.ps $convertArg $OPDir$OutTmp
done
echo "Removing Temporary Files"
rm $OPDir*.ncgm
rm TEMP.ps
echo -e "\033[1;33m=== Job Done ===\033[m"
