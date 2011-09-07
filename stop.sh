#!/bin/bash

mkfifo CPUIDLEPIPE
echo 'stop' > CPUIDLEPIPE
rm CPUIDLEPIPE
