#!/bin/bash

# Usage examples:
# env KIBANA_INDEX='.kibana_env1' ./load.sh
# ./load.sh -url http://test.com:9200
# ./load.sh -url http://test.com:9200 -user admin:secret
# ./load.sh -url http://test.com:9200 -index .kibana-test

# The default value of the variable. Initialize your own variables here
ELASTICSEARCH=http://{{elasticsearch_host }}:{{ elasticsearch_port }}
CURL="/usr/bin/curl"
KIBANA_INDEX="{{ kibana_index }}"

print_usage() {
  echo "
  
Load the dashboards, visualizations and index patterns into the given
Elasticsearch instance.

Usage:
  $(basename "$0") -url ${ELASTICSEARCH} -user admin:secret -index ${KIBANA_INDEX}

Options:
  -h | -help
    Print the help menu.
  -l | -url
    Elasticseacrh URL. By default is ${ELASTICSEARCH}.
  -u | -user
    Username and password for authenticating to Elasticsearch using Basic
    Authentication. The username and password should be separated by a
    colon (i.e. "admin:secret"). By default no username and password are
    used.
  -i | -index
    Kibana index pattern where to save the dashboards, visualizations,
    index patterns. By default is ${KIBANA_INDEX}.

" >&2
}

while [ "$1" != "" ]; do
case $1 in
    -l | -url )
        ELASTICSEARCH=$2
        if [ "$ELASTICSEARCH" = "" ]; then
            echo "Error: Missing Elasticsearch URL"
            print_usage
            exit 1
        fi
        ;;

    -u | -user )
        USER=$2
        if [ "$USER" = "" ]; then
            echo "Error: Missing username"
            print_usage
            exit 1
        fi
        CURL="curl --user ${USER}"
        ;;

    -i | -index )
        KIBANA_INDEX=$2
        if [ "$KIBANA_INDEX" = "" ]; then
            echo "Error: Missing Kibana index pattern"
            print_usage
            exit 1
        fi
        ;;

    -h | -help )
        print_usage
        exit 0
        ;;

     *)
        echo "Error: Unknown option $2"
        print_usage
        exit 1
        ;;

esac
shift 2
done

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${HERE}; 
BEATS="$(ls -d ${HERE}/*/ ;)"
echo "Loading dashboards to ${ELASTICSEARCH} in ${KIBANA_INDEX}"

# Workaround for: https://github.com/elastic/beats-dashboards/issues/94
${CURL} -XPUT "${ELASTICSEARCH}/${KIBANA_INDEX}"
${CURL} -XPUT "${ELASTICSEARCH}/${KIBANA_INDEX}/_mapping/search" -d'{"search": {"properties": {"hits": {"type": "integer"}, "version": {"type": "integer"}}}}'

for DIR in $BEATS
do
  cd ${DIR} 
    for FILE in $(ls ${DIR}/search/*.json;)
    do
        NAME=`basename ${FILE} .json`
        echo "Loading search ${NAME}:"
        ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/search/${NAME} \
            -d @${FILE} || exit 1
        echo
    done
    
    for FILE in $(ls ${DIR}/visualization/*.json;)
    do
        NAME=`basename ${FILE} .json`
        echo "Loading visualization ${NAME}:"
        ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/visualization/${NAME} \
            -d @${FILE} || exit 1
        echo
    done
    
    for FILE in $(ls ${DIR}/dashboard/*.json;)
    do
        NAME=`basename ${FILE} .json`
        echo "Loading dashboard ${NAME}:"
        ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/dashboard/${NAME} \
            -d @${FILE} || exit 1
        echo
    done
    
    for FILE in $(ls ${DIR}/index-pattern/*.json;)
    do
        NAME=`awk '$1 == "\"title\":" {gsub(/[",]/, "", $2); print $2}' ${FILE}`
        echo "Loading index pattern ${NAME}:"
    
        ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/index-pattern/${NAME} \
            -d @${FILE} || exit 1
        echo
    done
done


