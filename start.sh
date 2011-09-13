#!/bin/bash

progname=$1
shift
lua $progname.lua "$@" &
