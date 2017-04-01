# aasmith/cpu-agent

A tiny docker image for advertising the amount of CPU idle cycles that are
available.

## Why

Load balancers, such as haproxy can make weighting decisions based on the CPU
load of the servers in a given backend. (See `agent-check` in the haproxy
docs.)

## Details

The container runs `sar`, a tool for sampling CPU availability. This is
served up as a integer percentage using netcat.

CPU idle is never advertised to be below 1%. HAProxy (and possibly other
consumers) take action beyond simple weighting at this level.

The CPU sample is run on-demand, so there is a one second delay while the
sample is taken. An instant read would use the average idle time since
machine start, which is not desirable.

## Running

The image will need access to the host's pid list, so run the container as
such:

```
$ docker run -p 40000:40000 --pid=host aasmith/cpu-agent
```

This will expose the internal port as ephemeral port, suitable for
advertising through service discovery.

To test output, try the following (your variety of netcat may vary):

```
$ ncat --recv-only 127.0.0.1 40000
99%
```

