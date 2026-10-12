#!/usr/bin/env bash
# Runs the example's integration test on an iOS simulator. On fresh CI
# simulators the app sometimes launches before the system is ready and the VM
# service never comes up. Each drive gets 6 minutes in its own process group,
# and only a timed-out drive (exit 142) is retried, after the whole group is
# stopped and the simulator rebooted. Run from example/.
set -u
device=$1

boot() {
  xcrun simctl boot "$device" 2>/dev/null
  xcrun simctl bootstatus "$device" -b >/dev/null
  for _ in $(seq 1 24); do
    xcrun simctl launch "$device" com.apple.Preferences >/dev/null 2>&1 && break
    sleep 5
  done
  xcrun simctl terminate "$device" com.apple.Preferences >/dev/null 2>&1
  sleep 10
}

drive() {
  perl -e '
    my $seconds = shift;
    setpgrp(0, 0);
    my $pid = fork // die "fork: $!";
    unless ($pid) { exec @ARGV or die "exec: $!" }
    $SIG{ALRM} = sub {
      $SIG{TERM} = "IGNORE";
      kill "TERM", -$$;
      sleep 5;
      exit 142;
    };
    alarm $seconds;
    waitpid $pid, 0;
    exit($? & 127 ? 128 + ($? & 127) : $? >> 8);
  ' 360 flutter drive -d "$device" \
    --driver test_driver/integration_test.dart \
    --target integration_test/popover_test.dart
}

boot
status=0
for attempt in 1 2 3; do
  status=0
  drive || status=$?
  [ "$status" -ne 142 ] && break
  echo "Drive $attempt timed out, rebooting the simulator"
  xcrun simctl shutdown "$device"
  boot
done
xcrun simctl shutdown "$device"
exit $status
