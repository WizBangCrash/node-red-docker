if [ $# -ne 1 ]; then
    echo $0: usage: build.sh CONTAINER_VERSION
    exit 1
fi

CONTAINER_VERSION=$1

docker build --file latest/Dockerfile --tag node-red-homekit:$CONTAINER_VERSION .
# Make sure you have mounted smb://dixnas1.local/home on your iMac
docker image save -o /Volumes/home/Docker/node-red-homekit.tar node-red-homekit