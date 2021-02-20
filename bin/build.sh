#!/bin/bash
usage() {
cat <<-EOF
Usage is:
    ./setup.sh [-c] -n <NAME OF NEW IMAGE>
with required parameter:
    -n) the name of the new image
and optional:
    -c) a flag to force an image removal and system prune BEFORE building the image
EOF
exit 1
}

_name=''
unset _flag_clear
while getopts "cn:" opt; do
  case ${opt} in
    c)
      echo "pruning the image" >&2
      _flag_clear="yes"
    #   docker image rm -f ${_name} && docker system prune -f || echo "${_name} already pruned" >&2
      ;;
    n)
      _name=${OPTARG}
      ;;
    :) # If expected argument omitted:
      echo "Error: -${OPTARG} requires an argument."
      usage # Exit abnormally.
      ;;
    *) # If unknown (any other) option:
      usage # Exit abnormally.
      ;;
  esac
done

# if [[ -n ${_name} ]; then usage; fi 

docker image build -t ${_name} .
cat <<-EOF
docker container run --rm -it ${_name} sh
docker container run --name ${_name} --publish 80:3000 --rm ${_name}
docker container run --name ${_name} --publish 80:3000 --detach ${_name}
EOF
