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

## Example

For an example of a complete use case, see the [examples](examples)
directory for a haproxy config that uses an agent to achieve
weighted-round-robin load balancing.

## Real-World Usage

Google advocates for Weighted Round Robin with per-node CPU polling
in "(Site Reliability Engineering)[https://landing.google.com/sre/book]":

> Weighted Round Robin is an important load balancing policy that improves on Simple and Least-Loaded Round Robin by incorporating backend-provided information into the decision process.
>
> Weighted Round Robin is fairly simple in principle: each client task keeps a "capability" score for each backend in its subset. Requests are distributed in Round-Robin fashion, but clients weigh the distributions of requests to backends proportionally. In each response (including responses to health checks), backends include the current observed rates of queries and errors per second, in addition to the utilization (typically, CPU usage). Clients adjust the capability scores periodically to pick backend tasks based upon their current number of successful requests handled and at what utilization cost; failed requests result in a penalty that affects future decisions.
>
> In practice, Weighted Round Robin has worked very well and significantly reduced the difference between the most and the least utilized tasks.


