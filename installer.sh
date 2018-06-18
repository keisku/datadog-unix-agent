#!/bin/bash

START_PATH=$(pwd)
PSUTIL_WHEEL=./deps/psutil/psutil-5.4.5-cp27-cp27-aix_6_1.whl

if (( $# < 2 )); then
    echo "Illegal number of parameters"
elif (( $# == 3 )); then
    PSUTIL_WHEEL=$3
fi

which python2.7 > /dev/null
if [ $? -ne 0 ]; then
    echo "No python2.7 detected. Please install or fix PATH..."
    exit 1
fi

which virtualenv > /dev/null
if [ $? -ne 0 ]; then
    echo "No virtualenv detected. Please install or fix PATH."
    exit 1
fi

set -e

if [ -d $2 ]; then
    echo "Destination path exists its contents will be wiped"
    read -p "Are you sure? " -n 1 -r
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        rm -rf $2/datadog-unix-agent
    fi
fi

echo "Working off /tmp..."
cd /tmp

echo "Downloading tarball for branch $1"
curl -L -o datadog-unix-agent.tar.gz https://api.github.com/repos/DataDog/datadog-unix-agent/tarball/$1

# if there are dirs we cant read, the find will have $? > 0
set +e
echo "Removing old downloads if any..."
find . -type d -name 'DataDog-datadog-unix-agent*' -exec rm -rf {} \; 2>/dev/null 
set -e

echo "Unpacking tarball to destination $2..."
gunzip datadog-unix-agent.tar.gz
tar xvf datadog-unix-agent.tar
find . -type d -name 'DataDog-datadog-unix-agent*' 2>/dev/null | head -n 1 | xargs -t -I {} cp -R {} $2/datadog-unix-agent

echo "Setting up virtual env..."
cd $2/datadog-unix-agent
virtualenv venv
source ./venv/bin/activate

echo "Installing requirements..."
pip install $PSUTIL_WHEEL 
pip install -r ./requirements.txt
deactivate

echo "Cleaning up..."
rm /tmp/datadog-unix-agent.tar

echo "You should be good to go!"
cd $START_PATH 

set +e