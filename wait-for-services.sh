#!/bin/bash

# ex. usage :
#sudo bash ./wait-for-services.sh \
#    "http://$HOSTNAME:$AIRFLOW_WEBUI_PORT/health" "healthy" \
#    "http://$HOSTNAME:$JUPYTER_PORT/lab?token=$JUPYTER_TOKEN" "body" \
#    "http://$HOSTNAME:$OPENVSCODE_PORT/?folder=/opt/airflow/src&tkn=$OPENVSCODE_TOKEN" ""

T=3

# store partA & partB by iterating over arguments 2 by 2
list_partA=()
list_partB=()
for ((i=1; i<=$#; i+=2)); do
    list_partA+=("${!i}")
    j=$(($i + 1))
    list_partB+=("${!j}")
done 

echo ${list_partA[@]}
echo ${list_partB[@]}

all_services_ready=false
while ! $all_services_ready; do
    clear
    all_services_ready=true
    for ((i = 0; i < ${#list_partA[@]}; i++)); do
        partA="${list_partA[i]}"
        partB="${list_partB[i]}"
        if [ -z "$partB" ]; then
            echo -e "[--] $partA"
        elif [[ $partA == *http://* ]]; then
            url=$partA
            pattern=$partB
            if curl --silent $url | grep -E -q $pattern; then
                echo -e "[OK] $url"
            else
                echo -e "[KO] $url"
                all_services_ready=false
            fi
        else
            host=$partA
            port=$partB
            if nc -zw3 $host $port; then
                echo -e "[OK] $host:$port"
            else
                echo -e "[KO] $host:$port"
                all_services_ready=false
            fi
        fi
    done
    sleep $T
done
