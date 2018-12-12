#!/bin/bash

set -e

/opt/forger/auto_terminate/setup.sh

/opt/forger/auto_terminate.sh after_timeout

set +e
