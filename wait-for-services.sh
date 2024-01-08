#!/bin/bash

# ex. usage :
#sudo bash ./wait-for-services.sh \
#    "http://$HOSTNAME:$AIRFLOW_WEBUI_PORT/health" "healthy" \
#    "http://$HOSTNAME:$JUPYTER_PORT/lab?token=$JUPYTER_TOKEN" "body" \
#    "http://$HOSTNAME:$OPENVSCODE_PORT/?folder=/opt/airflow/src&tkn=$OPENVSCODE_TOKEN" ""

T=3

# store services & patterns by iterating over arguments 2 by 2
services=()
patterns=()
for ((i=1; i<=$#; i+=2)); do
    services+=("${!i}")
    j=$(($i + 1))
    patterns+=("${!j}")
done 

echo ${services[@]}
echo ${patterns[@]}

all_services_ready=false
while ! $all_services_ready; do
    clear
    sleep $T
    all_services_ready=true
    for ((i = 0; i < ${#services[@]}; i++)); do
        url="${services[i]}"
        pattern="${patterns[i]}"
        if [ -z "$pattern" ]; then
            echo -e "[--] $url"
        elif curl --silent $url | grep -E -q $pattern; then
            echo -e "[OK] $url"
        else
            echo -e "[KO] $url"
            all_services_ready=false
        fi
    done
done
