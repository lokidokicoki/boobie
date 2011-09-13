#!/bin/bash

progname=$1
shift
echo lua boobie.lua $progname "$@" &
lua boobie.lua $progname "$@" &
