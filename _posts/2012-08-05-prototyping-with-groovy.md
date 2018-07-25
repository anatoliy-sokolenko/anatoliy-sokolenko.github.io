---
title: "Prototyping with Groovy"
layout: "post"
permalink: "/2012/08/prototyping-with-groovy.html"
uuid: "7145325113912378974"
guid: "tag:blogger.com,1999:blog-1763451622132357586.post-7145325113912378974"
date: "2012-08-05 21:13:00"
updated: "2012-08-05 21:25:57"
description: 
blogger:
    siteid: "1763451622132357586"
    postid: "7145325113912378974"
    comments: "0"
tags: []
comments: true
share: true
categories: [trash]
---

Start of new software project is always complicated and fuzzy task. Best way to reduce it's complexity is to learn more about subject area, systems to integrate with and technologies that will be used. In solving all this issues prototyping might help dramatically.
One of the best languages for prototyping is Groovy. For many reasons starting from support of JVM as runtime environment, ending with fluen and easy to learn syntax.
Lets review some most valueable features of Groovy that might help with prototyping.

**Embedded support of Maven &amp; Ivy**
When trying to implement something quickly there is always a problem of managing dependencies. Which makes you either download full-blown set of dependencies or spent time on writing havy configuration XMLs. Groovy has nice feature which allows to reduce time on managing dependencies &mdash; [Grape](http://groovy.codehaus.org/Grapes+and+grab()). Grape allows simply annotate your code with dependencies on which it depends and runtime environment will take care of resolving those dependencies for you: 

{% gist galak/3201729 Grape.groovy %}

**Embedded support of relational databases**
Dispite the fact that NoSQL sollution are getting more pupolarity this days, relational storages still used in most of the applications.
Groovy provide [utilities to interact with SQL databases](http://groovy.codehaus.org/Database+features) in most convinient manner:

{% gist galak/3201729 JdbcGrape.groovy %}

@GrabConfig construction allows to work with JDBC drivers correctly. Without it Groovy would load each dependency in separate class loader and some libraries might work incorrectly.
Support of SQL statements is built into Groovy syntax. There is no need to define separate template. You can just use single query as both template and code:

{% gist galak/3201729 JdbcQuery.groovy %}

**Groovy supports both procedural and object-oriented programming**
With Groovy you can start with simple short scripts, but it is always possible to extend implementation to multiple classes and interfaces without changing programing language. 

**Groovy support both own and Java-oriented syntax**
Groovy syntax itself is extremly short and expressive, with huge set of utility methods it allows to write code really quickly. For example, imagine how much lines of code it would take you to simply print elements of array separated with comma:

{% gist galak/3201729 JdbcGrape.groovy %}

But if you would like to make your prototype code as close as possible to final solution you can always use Java syntax in Groovy code. It is supported for 99%. At least I could found only one annoyning difference — you can not use Java-like definition of array, it simply would not work.
Instead: 

{% gist galak/3201729 DefineArray.java %}

you must do

{% gist galak/3201729 DefineArray.groovy %}

Another good thing about Groovy is that it can be both precompiled and interpreted. 

**Groovy is functional language**
Funtional language become a buzz-word this days. But still it increses flexibility and simplysity of your code when it is written in functional paradigm:

{% gist galak/3201729 Find.groovy %}

Learning Groovy is as easy task. It is well [documented](http://groovy.codehaus.org/User+Guide) and [exhaustive cheatsheet is available](http://refcardz.dzone.com/refcardz/groovy).