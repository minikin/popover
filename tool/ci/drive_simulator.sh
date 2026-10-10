#!/usr/bin/env bash
# Runs the example's integration test on an iOS simulator. The first app launch
# on a fresh CI simulator can hang before the VM service comes up, so each drive
# gets 8 minutes and one retry. Run from example/.
set -u
device=$1
xcrun simctl boot "$device"
xcrun simctl bootstatus "$device" -b
xcrun simctl launch "$device" com.apple.Preferences >/dev/null
sleep 20
drive() {
  perl -e 'alarm shift; exec @ARGV' 480 flutter drive -d "$device" \
    --driver test_driver/integration_test.dart \
    --target integration_test/popover_test.dart
}
status=0
drive || drive || status=$?
xcrun simctl shutdown "$device"
exit $status
