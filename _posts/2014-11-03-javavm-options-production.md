---
title: "Java VM Options You Should Always Use in Production"
layout: "post"
permalink: "/2014/11/javavm-options-production.html"
description: 
tags: [java, production]
comments: true
share: true
categories: [blog]
---

This post is a cheatsheet with enumeration of options, which should be always used to configure Java Virtual Machine for **Web-oriented** server applications in production or production-like environments.

For lazy readers full listing is here (for curious detailed explanation is provided below):

* Java < 8

```
    -server
    -Xms<heap size>[g|m|k] -Xmx<heap size>[g|m|k]
    -XX:PermSize=<perm gen size>[g|m|k] -XX:MaxPermSize=<perm gen size>[g|m|k]
    -Xmn<young size>[g|m|k]
    -XX:SurvivorRatio=<ratio>
    -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled
    -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=<percent>
    -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark
    -XX:+PrintGCDateStamps -verbose:gc -XX:+PrintGCDetails -Xloggc:"<path to log>"
    -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M
    -Dsun.net.inetaddr.ttl=<TTL in seconds>
    -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=<path to dump>`date`.hprof
    -Djava.rmi.server.hostname=<external IP>
    -Dcom.sun.management.jmxremote.port=<port> 
    -Dcom.sun.management.jmxremote.authenticate=false 
    -Dcom.sun.management.jmxremote.ssl=false
```

* Java >= 8

```
    -server
    -Xms<heap size>[g|m|k] -Xmx<heap size>[g|m|k]
    -XX:MaxMetaspaceSize=<metaspace size>[g|m|k]
    -Xmn<young size>[g|m|k]
    -XX:SurvivorRatio=<ratio>
    -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled
    -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=<percent>
    -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark
    -XX:+PrintGCDateStamps -verbose:gc -XX:+PrintGCDetails -Xloggc:"<path to log>"
    -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M
    -Dsun.net.inetaddr.ttl=<TTL in seconds>
    -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=<path to dump>`date`.hprof
    -Djava.rmi.server.hostname=<external IP>
    -Dcom.sun.management.jmxremote.port=<port> 
    -Dcom.sun.management.jmxremote.authenticate=false 
    -Dcom.sun.management.jmxremote.ssl=false
```

### Make Server a Server

```
-server
```

Turns Java VM features specific to server applications, such as sofisticated JIT compiler. Though this option is implicitely enabled for x64 virtual machines, it still makes sence to use it as according to documentation behaviour maybe changed in the future.

### Make your Heap Explicit

```
-Xms<heap size>[g|m|k] -Xmx<heap size>[g|m|k]
```

To avoid dynamic heap resizing and lags, which could be caused by this, we explicitely specify minimal and maximal heap size. Thus Java VM will spend time only once to commit on all the heap.

```
-XX:PermSize=<perm gen size>[g|m|k] -XX:MaxPermSize=<perm gen size>[g|m|k]
```

Logic for permanent generation is the same as for overall heap &mdash; predefine sizing to avoid costs of dynamic changes. Not applicable to Java >= 8.

```
-XX:MaxMetaspaceSize=<metaspace size>[g|m|k]
```

By default Metaspace in Java VM 8 is not limited, though for the sake of system stability it makes sense to limit it with some finite value.

```
-Xmn<young size>[g|m|k]
```

Explicitely define size of the young generation.

```
-XX:SurvivorRatio=<ratio>
```

Ratio which determines size of the survivour space relatively to young generation size. Ratio can be calculated using following formula:
    
<script type="math/tex; mode=display" id="MathJax-Element-1">
\begin{aligned}
\verb|survivor ratio| = \dfrac{\verb|young size|}{\verb|survivor size|} - 2
\end{aligned} 
</script>
    

[Learn more](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html) and [this one too](http://javaeesupportpatterns.blogspot.com/2013/02/java-8-from-permgen-to-metaspace.html).

### Make GC Right

```
-XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled
```

As response time is critical for server application concurrent collector feets best for Web applications. Unfortunatelly G1 is still not production ready, thus we have to use Concurrent Mark-Sweep collector.

```
-XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=<percent>
```

By default CMS GC uses set of heuristic rules to trigger garbage collection. This makes GC less predictable and usually tends to delay collection until old generation is almost occupied. Initiating it in advance allows to complete collection before old generation is full and thus avoid Full GC (i.e. stop-the-world pause). ```-XX:+UseCMSInitiatingOccupancyOnly``` prevent usage of GC heuristics. ```-XX:CMSInitiatingOccupancyFraction``` informs Java VM when CMS should be triggered. Basically, it allows to create a buffer in heap, which can be filled with data, while CMS is working. Thus percent should be back calculated from the speed in which memory is consumed in old generation during production load. Such percent should be chosen carefully, if it will be small &mdash; CMS will work to often, if it will be to big &mdash; CMS will be triggered too late and [concurrent mode failure](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html#cms.concurrent_mode_failure) may occur.

```
-XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark
```

Instructs garbage collector to collect young generation before doing Full GC or CMS remark phase and as a result improvde their performance due to absence of need to check references between young generation and tenured.

[Learn more](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html) and [something fresh](http://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/index.html).

### GC Logging

```
-XX:+PrintGCDateStamps -verbose:gc -XX:+PrintGCDetails -Xloggc:"<path to log>"
```

These options make Java to log garbage collector activities into specified file. All records will be prepended with human readable date and time. Meanwhile you should avoid using ```-XX:+PrintGCTimeStamps``` as it will prepend record with useless timestamp since Java application start.

Generate log can be later analysed with [GCViewer](https://github.com/chewiebug/GCViewer).

```
-XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M
```

GC log files rotation makes analysis of garbage collection problems easier, also it guaranties that disk is protected from space overconsumption.


[Learn more](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html) and [a little bit more](http://176.34.122.30/blog/2010/05/26/human-readable-jvm-gc-timestamps/).

### DNS Caching

```
-Dsun.net.inetaddr.ttl=<TTL in seconds>
```

Number of seconds during which DNS record will be cached in Java VM. Default behaviour of Java VM 6 was to cache forever, which does not feet server application needs, as you would not want to restart server each time, when IP has changed in DNS record. It has been changed in Java VM 7 to cache for 30 seconds, but only if security manager is not installed. Depending on version of Java VM and presence of security manager DNS records still can be cached infinitely.
Commonly recommended option is to disable DNS caching at all, which can be reason for performance degradation. Requests to DNS are performed in synchorized block and only one request is performed in any point in time. Thus, if your application is havily utilizing network it will experience saturation on DNS requests, so TTL value ```0``` should **never** be used.

Better solution is to cache for reasonable not long period, for example 1 minute (```60``` seconds). This mean that system your application is interacting with have to guaranty that two different IPs will continue to work properly during this 1 minute, otherwise lower TTL value should be chosen. It should always be reasonable (not equal to ```0```) to prevent possible contention of requests to DNS. 

This option is convinient to use, but ```networkaddress.cache.ttl``` specified in %JRE%/lib/security/java.security should be considered as better solution, at least from official documentation prospective.

[Learn more](https://docs.oracle.com/javase/7/docs/technotes/guides/net/properties.html).

### Dump on Out of Memory

```
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=<path to dump>`date`.hprof
```

If your application would ever fail with out-of-memory in production, you would not want to wait for another chance to reproduce the problem. These options instruct Java VM to dump memory into file, when OOM occurred. It can cause considerable pauses on big heaps during OOM event. However, if Java VM is at OOM already, collecting as much information about the issue is more important than trying to serve traffic with completely broken application. We are also making sure the dump would be created with name unique per application start time (this is requeired because Java VM will fail to overwrite existing file).

[Learn more](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html).


### Make JMX work

```
-Djava.rmi.server.hostname=<external IP>
```

IP address, which would be embedded into RMI stubs sent to clients. Later clients will use this stubs to communicate with server via RMI. As in modern datacenters machine often has two IPs (internal and external) you would want explicitly specify which IP to use, otherwise JVM will make it's own choice. Correct value of this property is a precondition for successfully using JMX.

```
-Dcom.sun.management.jmxremote.port=<port> 
-Dcom.sun.management.jmxremote.authenticate=false 
-Dcom.sun.management.jmxremote.ssl=false
```

```-Dcom.sun.management.jmxremote``` option is not required starting from Java VM 6, however to make JMX available for remote access specific listen port should be provided. Later this port can be used to connect using any JMX tool (e.g. [VisualVM](http://visualvm.java.net/) or [Java Mission Control](http://www.oracle.com/technetwork/java/javaseproducts/mission-control/java-mission-control-1998576.html)).

Also to reduce additional trobelms with connecting disable standard authentication, but be sure that only authorized users can connect to environment using firewall. If for security reasons you still want to control access via standard mechanism [learn more](http://docs.oracle.com/javase/7/docs/technotes/guides/management/agent.html).

### P.S.
Many options that were previously very useful with updates in Java VM (specifically release of Java 7) are preconfigured by default:

* -XX:+UseCompressedOops
* -Dsun.rmi.dgc.server.gcInterval=3600000 and -Dsun.rmi.dgc.client.gcInterval=3600000
* -Dcom.sun.management.jmxremote
