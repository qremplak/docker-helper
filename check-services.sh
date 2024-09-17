#!/bin/bash

# ex. usage :
#sudo bash ./check-services.sh \
#    "http://$HOSTNAME:$AIRFLOW_WEBUI_PORT/health" "healthy" \
#    "http://$HOSTNAME:$JUPYTER_PORT/lab?token=$JUPYTER_TOKEN" "body" \
#    "http://$HOSTNAME:$OPENVSCODE_PORT/?folder=/opt/airflow/src&tkn=$OPENVSCODE_TOKEN" ""

# store partA, partB and partC by iterating over arguments 3 by 3
list_partA=()
list_partB=()
list_partC=()
for ((i=1; i<=$#; i+=3)); do
    list_partA+=("${!i}")
    j=$(($i + 1))
    list_partB+=("${!j}")
    k=$(($i + 2))
    list_partC+=("${!k}")
done 

echo ${list_partA[@]}
echo ${list_partB[@]}
echo ${list_partC[@]}

all_services_ready=true
for ((i = 0; i < ${#list_partA[@]}; i++)); do
    partA="${list_partA[i]}"
    partB="${list_partB[i]}"
    partC="${list_partC[i]}"
    if [ -z "$partC" ]; then
        echo -e "-- | $partA\t$partB"
    elif [[ $partB == *http://* ]]; then
        name=$partA
        url=$partB
        pattern=$partC
        if curl --silent $url | grep -E -q $pattern; then
            echo -e "OK | $name\t$url"
        else
            echo -e "KO | $name\t$url"
            all_services_ready=false
        fi
    else
        name=$partA
        host=$partB
        port=$partC
        if nc -zw3 $host $port; then
            echo -e "OK | $name\t$host:$port"
        else
            echo -e "KO | $name\t$host:$port"
            all_services_ready=false
        fi
    fi
done
