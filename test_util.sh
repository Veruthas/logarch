#!/bin/bash

source util.sh

declare command=$1; shift
$command "$@";
