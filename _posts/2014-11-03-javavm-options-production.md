---
title: "JavaVM Options You Should Always Use in Production"
layout: "post"
permalink: "/2014/11/javavm-options-production.html"
description: 
tags: [java, production]
comments: true
share: true
categories: [blog]
---

All together:

```

```


Table below is a cheatsheet with list of options, which should be always used to configure Java in Web-oriented server applications for production or production-like deployments.


-XX:PermSize=300M -XX:MaxPermSize=300M -Xss256K -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+CMSClassUnloadingEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:+CMSParallelRemarkEnabled  -XX:+CMSScavengeBeforeRemark 



-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false 
-Dfile.encoding=UTF-8 -Dlog4j.configuration=log4j_init_tomcat.properties -Djava.util.logging.config.file=jdk_logging.properties -Djava.io.tmpdir="${HYBRIS_TEMP_DIR}"



| Option                           | Description                                                                        |
|----------------------------------|------------------------------------------------------------------------------------|
|-server                           |Enables server feature of JVM, such as sofisticated JIT compiler.|
|-XX:+PrintGCDateStamps<br/>-verbose:gc<br/>-XX:+PrintGCDetails<br/>-Xloggc:"\<path to log>"[\*](http://176.34.122.30/blog/2010/05/26/human-readable-jvm-gc-timestamps/) [*](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)|These three options make Java to log garbage collector activities into specific file. All records will be prepended with human readable date and time. Meanwhile you should avoid using -XX:+PrintGCTimeStamps as it will prepend record with useless timestamp since Java application start.|
|-XX:+UseGCLogFileRotation<br/>-XX:NumberOfGCLogFiles=10<br/>-XX:GCLogFileSize=100M[*](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)|GC log files rotation makes analysis of garbage collection problems easier, also it guaranties that disk is protected from space overconsumption.|
|<span style="white-space:nowrap;">-Dsun.net.inetaddr.ttl=3600</span>[*](http://www.oracle.com/technetwork/java/javase/6u4-140071.html)       |Number of seconds during which DNS records will be cache in JVM.<br/>Default behavious of JVM is no caching, which can be reason for performance degradation. Requests to DNS are performed in *synchorized* block and only one request is performed in any point in time. Thus, if your application is havily utilizing network it will exirience saturation on in DNS requests.<br/>3600 stands for 1 hours, which default TTL for most DNS servers.<br/>This options is convinient to use, but _networkaddress.cache.ttl_ specified in %JRE%\lib\security should be considered as better solution, at least from official documentation prospective.|
|<span style="white-space:nowrap;">-XX:+HeapDumpOnOutOfMemoryError</span><br/>-XX:HeapDumpPath=\<path to dump>.hprof[\*](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)     |If your application would ever fail with out-of-memory in production, you would not want to wait for another chance to reproduce the problem. This options would instruct JVM to dump memory into file. The options can cause considerable pauses on big heaps during OOM event. However, if application is at OOM collecting as much information about the issue is more important than trying to serve trafic with completely broken application.          |
|-Djava.rmi.server.hostname=\<external IP>|IP address, which would be embedded into RMI stubs sent to clients. Later clients will use this stubs to communicate with server via RMI. As in modern datacenters machines often has two IPs (internal and external) you would want explicitly specify which IP to use, otherwise JVM will make it's own chose. Correct value of this property is a precondition for successfully using JMX.|
|-XX:+UseConcMarkSweepGC[\*](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html) [\**](http://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/index.html)|As response time is critical for server application concurrent collector feets best for Web applications. Unfortunatelly G1 is still not production ready.|
|-Xms\<heap size><br/>-Xmx\<heap size>[\*](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html)|To avoid dynamic heap resizing and lags, which could be caused by this we explicitely specify minimal and maximum heap size. Thus Java will spend time only once to commit on all the memory it will ever need.|
|-XX:PermSize=\<perm gen size><br/>-XX:MaxPermSize=\<perm gen size>|(Not applicable to Java >= 8) Logic is the same as for heap.|



For example (do not forget to change values for your environment):



### P.S.

To gain best performance not only Java VM start options should be properly configured operating system should be tunned as well. 






### P.S.
Many options that were previously very usefully with updates in JVM (specifically release of Java 7) are preconfigured by default:

* -XX:+UseCompressedOops
* -Dsun.rmi.dgc.server.gcInterval=3600000 and -Dsun.rmi.dgc.client.gcInterval=3600000


