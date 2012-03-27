#!/usr/bin/env bash
#
# unix_instruments
#
# A wrapper around `instruments` that returns a proper unix status code
# depending on whether the run failed or not. Alas, Apple's instruments tool
# doesn't care about unix status codes, so I must grep for the "Fail:" string
# and figure it out myself. As long as the command doesn't output that string
# anywhere else inside it, then it should work.
#
# I use a tee pipe to capture the output and deliver it to stdout
#
# Author: Jonathan Penn (jonathan@cocoamanifest.net)
#

set -e  # Bomb on any script errors

run_instruments() {
  # Because instruments buffers it's output if it determines that it is being
  # piped to another process, we have to use ptys to get around that so that we
  # can use `tee` to save the output for grepping and print to stdout in real
  # time at the same time.
  #
  # I don't like this because I'm hard coding a tty/pty pair in here. Suggestions
  # to make this cleaner?

  output=$(mktemp -t unix-instruments)
  instruments $@ &> /dev/ttyvf & pid_instruments=$!

  # Cat the instruments output to tee which outputs to stdout and saves to
  # $output at the same time
  cat < /dev/ptyvf | tee $output

  # Clear the process id we saved when forking instruments so the cleanup
  # function called on exit knows it doesn't have to kill anything
  pid_instruments=0

  # Process the instruments output looking for anything that resembles a fail
  # message
  cat $output | get_error_status
}

get_error_status() {
  # Catch "00-00-00 00:00:00 +000 Fail:"
  # Catch "Instruments Trace Error"
  ruby -e 'exit 1 if STDIN.read =~ /Instruments Trace Error|^\d+-\d+-\d+ \d+:\d+:\d+ [-+]\d+ Fail:/'
}

trap cleanup_instruments EXIT
function cleanup_instruments() {
  # Because we fork instruments in this script, we need to clean up if it's
  # still running because of an error or the user pressed Ctrl-C
  if [[ $pid_instruments -gt 0 ]]; then
    kill $pid_instruments
  fi
}

if [[ $1 == "----test" ]]; then
  get_error_status
else
  run_instruments $@
fi
