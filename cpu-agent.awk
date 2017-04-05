#!/usr/bin/awk -f

# Takes a floating-point CPU value, extracts the number as an
# integer, and appends a percent character. See comments below
# for more details. For example, 23.67 becomes 24%.

BEGIN {
  statefile = "/var/run/cpu-agent.prev"

  # Read the previous CPU idle value. If the statefile does
  # not exist, or is empty, then assume 100.
  if (getline prev < statefile < 1) prev = 100

  # Close the file so it can be written to later on.
  close(statefile)
}

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

  # Take the current and previous CPU idle value, and cap the
  # new value to a max of prev + 3. This prevents a node from
  # immediately jumping to full-idle, and possibly taking on
  # too much load, sending the node idle back to near-zero.
  cpu = (cpu - 3 > prev) ? prev + 3 : cpu

  # Save the new cpu value to the state file.
  print cpu > statefile

  printf("%.0f%%\r\n", cpu)
}
