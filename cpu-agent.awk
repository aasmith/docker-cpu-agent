#!/usr/bin/awk -f

# Takes a floating-point CPU value, extracts the number as an
# integer, and appends a percent character. See comments below
# for more details. For example, 23.67 becomes 24%.

BEGIN {
  # Maximum cpu idle increase allowed per interval.
  maxrise = 3

  # Amount of time to keep a previous cpu idle value in seconds.
  interval = 5

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

  # If the cpu idle value is higher than previous, and the
  # statefile is less than five seconds old, then return the old
  # number instead. This prevents the number from climbing too
  # rapidly, but still allows it to drop instantly.

  if (getline < statefile > 0) {
    # Fetch the state file's mtime and the current time.
    "date -r " statefile " +%s" | getline prevtime
    now = systime()

    close(statefile)

    # If the state file is newer than 5 seconds, print and exit.
    if (prevtime > now - interval && cpu > prev) {
      printf("%.0f%% #C\r\n", prev)
      exit
    }
  }

  # Take the current and previous CPU idle value, and cap the
  # new value to a max of prev + 3. This prevents a node from
  # immediately jumping to full-idle, and possibly taking on
  # too much load, sending the node idle back to near-zero.
  cpu = (cpu - maxrise > prev) ? prev + maxrise : cpu

  # Save the new cpu value to the state file.
  print cpu > statefile

  printf("%.0f%%\r\n", cpu)
}
