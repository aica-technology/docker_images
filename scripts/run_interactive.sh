#!/bin/bash

IMAGE_NAME=""
CONTAINER_NAME=""
USERNAME=""

HELP_MESSAGE="
Usage: ./run_interactive.sh <image> [-n <name>] [-u <user>]

Run a docker container as an interactive shell.

Options:
  -i, --image <name>       Specify the name of the docker image.
                           (required)

  -n, --name <name>        Specify the name of generated container.
                           By default, this is deduced from
                           the image name, replacing all
                           '/' and ':' with '-' and appending
                           '-runtime'. For example, the image
                           aica-technology/ros2-ws:foxy would yield
                           aica-technology-ros2-ws-foxy-runtime

  -u, --user <user>        Specify the name of the login user.
                           (optional)

  -v, --volume </local/path:/remote/path>   Specify a volume to
                           mount between the host and container
                           as two full paths separated by a ':'.

  -h, --help               Show this help message."


RUN_FLAGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -i|--image) IMAGE_NAME=$2; shift 2;;
    -n|--name) CONTAINER_NAME=$2; shift 2;;
    -u|--user) USERNAME=$2; shift 2;;
    -v|--volume) RUN_FLAGS+=(-v "$2"); shift 2;;
    -h|--help) echo "${HELP_MESSAGE}"; exit 0;;
    -*) echo "Unknown option: $1" >&2; echo "${HELP_MESSAGE}"; exit 1;;
    *) IMAGE_NAME=$1; shift 1;;
  esac
done

if [ -z "$IMAGE_NAME" ]; then
  echo "No image name provided!"
  echo "${HELP_MESSAGE}"
  exit 1
fi

if [ -z "$CONTAINER_NAME" ]; then
  CONTAINER_NAME="${IMAGE_NAME/\//-}"
  CONTAINER_NAME="${CONTAINER_NAME/:/-}-runtime"
fi

if [ -z "$USERNAME" ]; then
  RUN_FLAGS+=(-u "${USERNAME}")
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  DISPLAY_IP=$(ifconfig en0 | grep "inet" | cut -d\  -f2)
  RUN_FLAGS+=(-e DISPLAY="${DISPLAY_IP}")
else
  xhost +
  RUN_FLAGS+=(-e DISPLAY="${DISPLAY}")
  RUN_FLAGS+=(-e XAUTHORITY="${XAUTH}")
fi

docker run -it --rm \
  "${RUN_FLAGS[@]}" \
  --name "${CONTAINER_NAME}" \
  --hostname "${CONTAINER_NAME}" \
  "${IMAGE_NAME}"