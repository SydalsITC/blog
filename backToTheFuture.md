
# Back to the future

## TL;DR
It's difficult to shift a container in time because you cannot modify the clock of the worker node
without mixing up Kubernetes. By using libfaketime and injecting it over a secret mounted as a volume,
it's possible to let each container run in its own time bubble.

## Shift in time
When testing an application to see how it behaves at a special point in time in the future,
e.g. at turn of the year or another special date when fiscal regulations change,
one usually puts it onto a VM and turns the clock of the latter forward.
In the world of Kubernetes, this is not possible. You never know on which node the
container with your app ist placed, and if you pin it (e.g. by labeling), twisting
the nodes clock would mess up Kubernetes and disconnect the node from the master.
You would need to place a whole Kubernetes cluster for each application
_and_ time jump which would consume lots of resources.

An easy and software based alternative is the open source library libfaketime.
By using the Preload mechanism of the Linux Loader, it can be placed between libc
and the spawned process where it intercepts system calls regarding time functions
and manipulates them. The preloading is done with the environment variable
_LD_PRELOAD_ which needs to contain the path to the library.

For most Linux distributions there's a package for libfaketime so that installation is done easily, e.g.
```
debian# apt-get install libfaketime
redhat# yum install libfaketime
```

Parameters for libfaketime are transported over environment variables, too. The most important
is FAKETIME which contains the starting point in time for the process or a relatice offset which
is added (or, when negative, subtracted) from the outside real time. In a standard Linux
environment this would be done like this:
```
$ LD_PRELOAD=/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1  FAKETIME=+365d  date -Idate
2022-07-05
$ date -Idate
2021-07-05
$
```

## Shipping containers
When loading a container with LD_PRELOAD'ing libfaketime, its internal process #1 and thus
the whole container gets shifted in time.  LD_PRELOAD and other parameters for libfaketime 
would be given end environment variables in the env: block. The lines needed in a deployment
would look much like this:
```
    spec:
      containers:
        - name: backintime
          image: ubuntu:18.04
          # ...
          env:
            - name: "LD_PRELOAD"
              value: "/usr/lib64/faketime/libfaketime.so.1"
            - name: "FAKETIME"
              value: "+1000d"
            - name: "FAKETIME_DONT_FAKE_MONOTONIC"
              value: "1"
```
First action of the container would be to load the library. Every process spawned afterwards would
be told date and time with the delta given in FAKETIME.

But how to place the libfaketime library inside the container? The image is immutable. So the next
best way is to use a volume. Because providing the library would need a read only, immutable volume,
we can resort to a trick, using a secret as storage. The binary of the library ets converted to a
base64 encoded string before being placed into a secret:
```
---
# contains libfaketime library
apiVersion: v1
kind: Secret
metadata:
  name: faketime-volume
type: Opaque
data:
  libfaketime.so.1: f0VMRgIBAQAAAAAAAAAAAAMAPgABAA...
```
## A secre volume
The secret gets mounted as volume into te container. That way the libary gets provided before starting
the container so that LD_PRELOAD can easily load it.

The decisive code line would look like this:
```
    spec:
      containers:
        - name: backintime
          image: ubuntu:18.04
          # ...
          volumeMounts:
            - mountPath: "/usr/lib64/faketime"
              name: faketime-volume
              readOnly: true
      volumes:
        - name: faketime-volume
          secret:
            secretName: faketime-volume
```
Assuming that the container would print its "current" date and time to stdout every fice seconds,
the log output would look like this:

```
$ kubectl logs backintime-abcde

Fri Mar 29 21:37:45 UTC 2024
Fri Mar 29 21:37:50 UTC 2024
Fri Mar 29 21:37:55 UTC 2024

```

A example deployment may be found in the file [backToTheFuture/deployment.yaml](backToTheFuture/deployment.yaml).
The [accompanying shell script](backToTheFuture/generate_secret.sh) generates the yaml for secret, provided that the libfaketime library is installed.

## Summary
Shifting a Kubernetes cluster in time is not desirable. If you need to shift a container in time, you may
use libfaketime. Injecting the library via a secret which gets mounted as volume makes it possible to
preload it and thus to modify the time for all processes inside the container that request timestamps
via standard libc functions.

## Links
* Github repo of [libfaketime](https://github.com/wolfcw/libfaketime)
* [LD_PRELOAD trick](https://stackoverflow.com/questions/426230/what-is-the-ld-preload-trick#426260)
* [Using Secrets as files from a Pod](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod)
