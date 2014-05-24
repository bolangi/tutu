#!/bin/sh
source ~/.bashrc
exec `dirname $0`/plack_runner.pl ${1+"$@"}
