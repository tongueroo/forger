#!/bin/bash

# extract forger happens very early and the top of the user data script.
# Set the -e flag here to stop the script if there any errors.
set -e

# Downloads and extract the scripts.
# The extracted folder from github looks like this:
#   branch-name.tar.gz => forger-branch-name
#   master.tar.gz => forger-master
#   v1.0.0.tar.gz => forger-1.0.0
function extract_forger_scripts() {
  local temp_folder
  local url
  local filename

  rm -rf /opt/forger   # clean start

  temp_folder="/opt/forger-temp"
  rm -rf "$temp_folder"
  mkdir -p "$temp_folder"

  (
    cd "$temp_folder"

  <%
    # Examples:
    #   FORGER_CODE=v1.0.0
    #   FORGER_CODE=master
    #   FORGER_CODE=branch-name
    #
    #   https://github.com/tongueroo/forger/archive/v1.0.0.tar.gz
    #   https://github.com/tongueroo/forger/archive/master.tar.gz
    code_version = ENV['FORGER_CODE']
    code_version ||= "v#{Forger::VERSION}"
  %>
    url="https://github.com/tongueroo/forger/archive/<%= code_version %>.tar.gz"
    filename=$(basename "$url")
    folder="${filename%.tar.gz}" # remove extension
    folder="${folder#v}" # remove leading v character
    folder="forger-$folder" # IE: forger-1.0.0

    # install wget if not installed
    if ! type wget > /dev/null 2>&1 ; then
      if type yum > /dev/null 2>&1 ; then
        yum install -y wget
      elif type apt-get > /dev/null 2>&1 ; then
        apt-get update
        apt-get install -y wget
      fi
    fi

    # install tar if not installed
    if ! type tar > /dev/null 2>&1 ; then
      if type yum > /dev/null 2>&1 ; then
        yum install -y tar
      elif type apt-get > /dev/null 2>&1 ; then
        apt-get update
        apt-get install -y tar
      fi
    fi

    wget "$url"
    tar zxf "$filename"

    mv "$temp_folder/$folder/lib/forger/scripts" /opt/forger
    rm -rf "$temp_folder"
    chmod a+x -R /opt/forger
  )
}

extract_forger_scripts

set +e
