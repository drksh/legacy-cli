#!/bin/bash

#init variables
submission_type="u"
submission_chosen=false
submission_action="view"
submission_action_chosen=false

authentication=""
password=""

# get last argument
for i in $@; do :; done
last_arg=$i

# validation functions
function validate_submission_choice {
    if [[ $submission_chosen = true ]]; then
        echo "Only one of the folowing can be chosen:"
        echo "-s (snippet) -f (file) -u (url)"
        exit
    else
        submission_chosen=true
    fi
}

function validate_submission_action {
    if [[ $submission_action_chosen = true ]]; then
        echo "Only one of the folowing can be chosen:"
        echo "-c (create|default)"
        exit
    else
        submission_action_chosen=true
    fi
}

# soruce: http://stackoverflow.com/a/10660730
rawurlencode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    #echo "${encoded}"    # You can either set a return variable (FASTER) 
    REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

# check arguments
while getopts sfucvp:a: option
do
    case "${option}"
    in
        s) 
            validate_submission_choice
            submission_type="s";
            ;;
        f)
            validate_submission_choice
            submission_type="f";
            ;;
        u)
            validate_submission_choice
            submission_type="u";
            ;;
        c)
            validate_submission_action
            submission_action="create"
            ;;
        v)
            validate_submission_action
            submission_action="view"
            ;;
        p)
            password=$OPTARG
            ;;
        a)
            authentication=$OPTARG
            ;;
    esac
done

if [[ $submission_chosen == false ]]; then
    echo "Choose one of the following options:"
    echo "-s (snippet) -f (file) -u (url)"
    exit
fi

## Snippets
if [[ $submission_type = "s" ]]; then

    # needs file as last agrument
    if [[ $last_arg == -* ]]; then
        echo "Please supply a last argument."
        exit
    fi

    # view a snippet
    if [[ $submission_action == "view" ]]; then
        curl_cmd="curl -s -X GET "

        if [[ -n $authentication ]]; then
            curl_cmd="$curl_cmd -u $authentication"
        fi

        if [[ -n $password ]]; then
            curl_cmd="$curl_cmd $last_arg?password=$password"
        else
            curl_cmd="$curl_cmd $last_arg"
        fi

        response=$($curl_cmd)

        echo "$response"
    fi

    if [[ $submission_action == 'create' ]]; then

        # if file exists
        if [[ -f $last_arg ]]; then

            curl_cmd="curl -X POST "

            if [[ -n $authentication ]]; then
                curl_cmd="$curl_cmd -u $authentication"
            fi
            
            cat_output=`cat $last_arg`
            #cat_output="onetwothree"

            rawurlencode "$cat_output"; cat_output=${REPLY}

            curl_cmd="$curl_cmd -d body=$cat_output http://darkshare.app/s"

            response=$($curl_cmd)
            #response="$curl_cmd"

            echo $response

        else
            echo "File $last_arg not found."
            exit
        fi

    fi
    
fi

# Files
if [[ $submission_type = "f" ]]; then

    if [[ $last_arg == -* ]]; then
        echo "Please supply a last argument."
        exit
    fi

    if [[ $submission_action == "view" ]]; then
        echo "Downloading file: $last_arg"
    fi

    if [[ $submission_action == 'create' ]]; then

        # if file exists
        if [[ -f $last_arg ]]; then
            echo "Created filet: http://drk.sh/s/aV"
        else
            echo "File $last_arg not found."
            exit
        fi

    fi
    
fi

# URL's
if [[ $submission_type = "u" ]]; then

    if [[ $last_arg == -* ]]; then
        echo "Please supply a last argument."
        exit
    fi

    if [[ $submission_action == "view" ]]; then
        echo "Destination of URL is: http://duckduckgo.com"
    fi

    if [[ $submission_action == 'create' ]]; then

        # if file exists
        echo "Shortened url to: http://drk.sh/s/aV"

    fi
    
fi

