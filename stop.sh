#!/bin/bash

mkfifo BOOBIE_PIPE
echo 'stop' > BOOBIE_PIPE
rm BOOBIE_PIPE
