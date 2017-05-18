function download() {

    local imageDownloadURL="$1"
    local imageSavePath="$2"

    echo -en "$CLI_PREFIX Fetching meta data..."

    #Get the actual download URL of the image
    imageDownloadURL=`curl -sIL "$imageDownloadURL" -o /dev/null -w %{url_effective}`

    #Get the HTTP headers for the image
    IMAGE_HEADERS=`curl -sI "$imageDownloadURL"`

    #Get the HTTP response code
    [[ $IMAGE_HEADERS =~ $regexHTTPCode ]]
    IMAGE_RESPONSE_CODE="${BASH_REMATCH[1]}"
    IMAGE_RESPONSE_MSG="${BASH_REMATCH[2]}"

    if [ "$IMAGE_RESPONSE_CODE" != 200 ]; then
        echo " FAIL"
        echo -e "$CLI_PREFIX Download Error [HTTP $IMAGE_RESPONSE_CODE $IMAGE_RESPONSE_MSG]"
        exit
    else
        echo " OK"
    fi

    #Get the image size
    [[ $IMAGE_HEADERS =~ $regexSize ]]
    IMAGE_SIZE="${BASH_REMATCH[1]}"

    #Check if we already have this version
    if [ ! -f "$imageSavePath" ]; then
        #Download the image
        curl -sL "$imageDownloadURL" | pv -s "$IMAGE_SIZE" -cN "Download" > "$imageSavePath"
        return 0
    else
        return 2
    fi

    # Check the file was created
    if [ ! -f "$imageSavePath" ]; then
        return 1
    fi

}
