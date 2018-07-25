---
title: "Buggy For loop in Java VM 6 x64"
layout: "post"
permalink: "/2011/10/buggy-for-loop-in-java-vm-6-x64.html"
uuid: "7888394236197116475"
guid: "tag:blogger.com,1999:blog-1763451622132357586.post-7888394236197116475"
date: "2011-10-14 06:55:00"
updated: "2011-10-14 06:57:40"
description: 
blogger:
    siteid: "1763451622132357586"
    postid: "7888394236197116475"
    comments: "0"
tags: []
comments: true
share: true
categories: [trash]
---

I have faced extremely weird bug in Java VM x64 yesterday. 
For loop in the following snippet will end at n == 15588, which obviously not greater that Integer.MAX_VALUE. 
Looks like it is bug of x64 version only. At least on x32 of same version everything works fine.

```java
import java.util.*;

class ForBug {
    public static void main( String[] a ) {
        int m = Integer.MAX_VALUE;

        for ( int n = 1; n <= m; n++ ) {
            System.out.println( "Step " + n );
        }
    }
}
```

Tested on:

```text
java version "1.6.0_27"
Java(TM) SE Runtime Environment (build 1.6.0_27-b07)
Java HotSpot(TM) 64-Bit Server VM (build 20.2-b06, mixed mode)
```

and

```text
java version "1.6.0_26"
Java(TM) SE Runtime Environment (build 1.6.0_26-b03)
Java HotSpot(TM) 64-Bit Server VM (build 20.1-b02, mixed mode)
```

Everything looks fine with While loop.
Have reported a bug on <a href="http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=7100905">http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=7100905</a>.
