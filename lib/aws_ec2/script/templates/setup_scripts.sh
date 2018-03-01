#!/bin/bash

# https://github.com/tongueroo/aws-ec2/archive/v1.0.0.tar.gz
# https://github.com/tongueroo/aws-ec2/archive/master.zip
# https://github.com/tongueroo/aws-ec2/archive/master.tar.gz
# https://github.com/tongueroo/aws-ec2/archive/v1.0.0.zip

# Downloads and extract the scripts.
# The extracted folder from github looks like this:
#   branch-name.tar.gz => aws-ec2-branch-name
#   master.tar.gz => aws-ec2-master
#   v1.0.0.tar.gz => aws-ec2-1.0.0
function setup_scripts() {
  local temp_folder
  local url
  local filename

  temp_folder="/opt/aws-ec2-temp"
  rm -rf "$temp_folder"
  mkdir -p "$temp_folder"
  cd "$temp_folder"

  url="https://github.com/tongueroo/aws-ec2/archive/v<%= AwsEc2::VERSION %>.tar.gz"
  # hard code to branch for testing
  url="https://github.com/tongueroo/aws-ec2/archive/auto-terminate.tar.gz"
  filename=$(basename "$url")
  folder="${filename%.tar.gz}" # remove extension
  folder="${folder#v}" # remove leading v character
  folder="aws-ec2-$folder" # IE: aws-ec2-1.0.0

  wget "$url"
  tar zxf "$filename"

  mv "$temp_folder/$folder/lib/aws_ec2/scripts" /opt/aws-ec2
  chmod a+x -R /opt/aws-ec2
}

setup_scripts
