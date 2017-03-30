#!/usr/bin/awk

# Takes a floating-point CPU value, extracts the number as an
# integer, and appends a percent character. See comments below
# for more details. For example, 23.67 becomes 24%.

END {
  cpu = $NF

  # If the field is not a usable number, (i.e. does not start
  # with a digit), then ignore the input and report back as
  # being able to accept at the normal rate (100%).
  if (cpu !~ /^[0-9]/) cpu = 100

  # If CPU is below 1% idle (!), then report back the minimum
  # allowed value of 1%. Upstream consumers may take more
  # evasive action at zero, potentially causing more distress.
  if (cpu <= 1) cpu = 1

  printf("%.0f%%\r\n", cpu)
}
