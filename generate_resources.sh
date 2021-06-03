#!/bin/sh

## Generate Optimized Resources

#
#  *********************************************************************************
#  ** Copyright (c) 2021 Sujaykumar.Hublikar <hello@sujaykumarh.com>              **
#  **                                                                             **
#  ** Licensed under the Apache License, Version 2.0 (the "License");             **
#  ** you may not use this file except in compliance with the License.            **
#  ** You may obtain a copy of the License at                                     **
#  **                                                                             **
#  **       http://www.apache.org/licenses/LICENSE-2.0                            **
#  **                                                                             **
#  ** Unless required by applicable law or agreed to in writing, software         **
#  ** distributed under the License is distributed on an "AS IS" BASIS,           **
#  ** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    **
#  ** See the License for the specific language governing permissions and         **
#  ** limitations under the License.                                              **
#  **                                                                             **
#  *********************************************************************************


## Global Variables
CURRENT_DIR=`pwd`
LOG_DIR="$CURRENT_DIR/logs"

## Packges needed
pkgsNeeded=(
    inkscape    # process svg
    scour       # optimize svg
    gimp        # process images
    exiv2       # modify EXIF data
)

# loop required packages
for _pkg in "${pkgsNeeded[@]}"
do
    # Check fi package available
    if ! which $_pkg &>/dev/null ; then
        echo -e "⛔ $_pkg \twas not found and is required"
        exit
    fi
    echo -e "✅ $_pkg \tinstalled"
done
echo "" #emptyline



## Create Dir if it does'nt exist
createDir(){
    #   usage: createDir /path/to/create/directory

    _directory="$1"
    # make directory if it doesnt exist
    if [ ! -d "$_directory" ]; then
        _folder=`echo $_directory | rev | cut -f 1-4 -d '/' | rev`   # get relative path to last 4 /
        echo -e "$_folder \t folder not found creating.."
        mkdir -p "$_directory"
    fi
}

## inkscape export SVG
exportSVG(){
    # Usage:    exportSVG inputSVG outputFile resolution [extra]

    inputSVG="$1"
    outputFile="$2"
    resolution="$3"
    extra="${@:4}"  # arguments 4 onwards

    echo "Exporting SVG: `basename $inputSVG` >> `echo $outputFile | rev | cut -f 1-3 -d '/' | rev`"

    # inkscape export image
    inkscape \
        $extra \
        -w $resolution \
        $inputSVG \
        -o $outputFile \
        2> $LOG_DIR/inkscape.log
}


## Scour to optimize SVG
optimizeSVG(){
    # Usage:    optimizeSVG inputSVG outputSVG

    inputSVG="$1"
    outputSVG="$2"

    echo "Optimizing SVG: `basename $inputSVG` >> `echo $outputSVG | rev | cut -f 1-3 -d '/' | rev`"

    # scour
    scour \
        --no-line-breaks \
        --indent=none \
        --enable-comment-stripping \
        --disable-embed-rasters \
        --shorten-ids \
        --enable-id-stripping \
        --set-precision=5 \
        --renderer-workaround \
        -i $inputSVG \
        -o $outputSVG \
        >> $LOG_DIR/scour.log
}


MetaArtist="Sujaykumar Hublikar <hello@sujaykumarh.com>"
MetaCopyright="Copyright (c) Sujaykumar Hublikar <hello@sujaykumarh.com>"
MetaComment="$MetaCopyright Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (http://creativecommons.org/licenses/by-nc-sa/4.0/)"


# echo "" #emptyline

## Add EXIF data to images
addEXIFData(){
    # Usage:    addEXIFData inputImage [software]

    file="$1"
    MetaSoftware="$2"

    if [ ! -f $file ];then
        echo "File `basename $file` not found!"
        return
    fi

    echo "Updating EXIF data of `basename $file`"

    exiv2 \
        -M "set Exif.Image.Copyright    $MetaCopyright" \
        -M "set Exif.Image.Artist       $MetaArtist" \
        -M "set Exif.Photo.UserComment  $MetaComment" \
        -M "set Exif.Image.Software     $MetaSoftware" \
        $file
}

copyREADME_LICENSE(){
    # Usage:    copyREADME_LICENSE INPUT_FOLDER OUTPUT_FOLDER README_STRING

    INPUT_FOLDER="$1"
    OUTPUT_FOLDER="$2"
    README_STRING="$3"

    # copy readme
    if [ -f "$INPUT_FOLDER/README.md" ]; then
        cp $INPUT_FOLDER/README.md $OUTPUT_FOLDER/README.md

        echo "Copied README to `echo $OUTPUT_FOLDER | rev | cut -f 1-3 -d '/' | rev`"

        # Edit readme file
        README_FILE="$OUTPUT_FOLDER/README.md"

        STRING="\#\ ImagesInFolder"
        NEWSTRING="\#\ $README_STRING Images"
        sed -i -e "s/$STRING/$NEWSTRING/g" $README_FILE
        echo "Updated README.md"
    else
        echo "README not found in `echo $INPUT_FOLDER | rev | cut -f 1-3 -d '/' | rev`"
    fi

    # copy license
    if [ -f "$INPUT_FOLDER/LICENSE" ]; then
        cp $INPUT_FOLDER/LICENSE $OUTPUT_FOLDER/LICENSE
        echo "Copied LICENSE `echo $INPUT_FOLDER | rev | cut -f 1-3 -d '/' | rev`"
    else
        echo "LICENSE not found in `echo $INPUT_FOLDER | rev | cut -f 1-3 -d '/' | rev`"
    fi
}


###
## Process Images in `./images` directory
###

SRC_DIR="$CURRENT_DIR/docs"                     ## project source

IMG_INPUT_DIR="$CURRENT_DIR/images"             ## images input directory
IMG_OUT_DIR="$SRC_DIR/assets/images"            ## images output directory

IMG_README_SRC="$IMG_INPUT_DIR/README.md"       ## image README.md to copy to output dir
IMG_LICENSE_SRC="$IMG_INPUT_DIR/LICENSE"        ## image LICENSE to copy to output dir

## Process SVGs ./images/folderName
Folders=(
    "avatar"            # avatar image
    "svg"               # svgs
    "bg"                # backgrounds
    "illustrations"     # illustrations used in page
)

processSVGs(){

    # loop over folders to process
    for Folder in "${Folders[@]}"
    do
        echo "" # emptyline

        shopt -s nullglob


        InputDir="$IMG_INPUT_DIR/$Folder"
        OutputDir="$IMG_OUT_DIR/$Folder"

        # echo "INPUT : $InputDir"
        # echo "OUTPUT: $OutputDir"

        # create directory if does'nt exist
        createDir $OutputDir

        ## Optimize SVGs
        for inputSVG in $InputDir/*.svg
        do
            echo "" # emptyline

            file=`basename $inputSVG`
            echo "Processing Image: $file"

            InputSVG="$inputSVG"
            OutputSVG="$OutputDir/$file"

            optimizeSVG $InputSVG $OutputSVG            # optimize svg
        done

        echo "" #emptyline

        copyREADME_LICENSE $IMG_INPUT_DIR $OutputDir $Folder

        # unset shopt
        shopt -u nullglob
    done
}



## Process Images ./images/folderName
Folders=(
    "gallery"           # My Image Gallery
)

processImages(){
    # loop over folders to process
    for Folder in "${Folders[@]}"
    do
        echo "" # emptyline

        shopt -s nullglob


        InputDir="$IMG_INPUT_DIR/$Folder"
        OutputDir="$IMG_OUT_DIR/$Folder"

        # echo "INPUT : $InputDir"
        # echo "OUTPUT: $OutputDir"

        # create directory if does'nt exist
        createDir $OutputDir

        ## Optimize Images
        for inputImg in $InputDir/*.{png,jpg,jpeg};
        do
            echo "" # emptyline
            file=`basename $inputImg`
            echo "Copying Image: $file >> `echo $OutputDir | rev | cut -f 1-3 -d '/' | rev`"
            cp $inputImg $OutputDir

            addEXIFData "$OutputDir/$file"  # add EXIF to image
        done

        echo "" #emptyline

        copyREADME_LICENSE $IMG_INPUT_DIR $OutputDir $Folder

        # unset shopt
        shopt -u nullglob
    done
}


processFavicon(){

    ## Generate Favicon
    FaviconSVG="favicon.svg"
    FaviconImg="favicon.png"

    FaviconRES="512"            ## 512px Favicon png

    InputDir="$IMG_INPUT_DIR/favicon"     ## input dir
    OutputDir="$IMG_OUT_DIR"

    InputSVG="$InputDir/$FaviconSVG"

    OutputSVG="$OutputDir/$FaviconSVG"
    OutputFile="$OutputDir/$FaviconImg"

    ## Process Image
    echo "" #emptyline
    echo "Processing `basename $InputSVG`..."

    createDir $OutputDir                        # create directory if does'nt exist

    optimizeSVG $InputSVG $OutputSVG            # optimize svg

    exportSVG $InputSVG $OutputFile $FaviconRES # export svg
    addEXIFData $OutputFile "avatar from getavataaars.com"  # add EXIF to image
}

processFavicon
processSVGs
processImages