#!/bin/sh

ncat -p 40000 --send-only -lkc "sar -u 1 1 | awk -f cpu-agent.awk"
