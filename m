From: Alex Gartrell <agartrell@fb.com>
Subject: We've released a generic netlink python library -- gnlpy
Date: Wed, 20 May 2015 14:10:19 -0700
Message-ID: <555CF83B.7040706@fb.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : content-type :
 content-transfer-encoding; s=facebook;
 bh=gEl+bG4zGqT6NyFPEP7JdQY9l1Qc8kRSBDXeb2tFnto=;
 b=IjLmgHpOFUc/PPBxz9b7ZMuhzfZUspOp96c0mHfcROUcLfYF3NPYFt6IfS4Jla8gr5CS
 9Vl0fbQ15kGgahN4qvQSThpYNIfpso6BRCOOcnILf2zd15MAnnG3/DAN3yrUghqIvJIw
 3/ALl5GQx9t4VzBjFYRdKYhdC1atJ7IbfAc= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: kernel-team@fb.com

Hey everyone,

tl;dr; pure python generic netlink library with simple clients for ipvs 
and taskstats here: https://github.com/facebook/gnlpy

At Facebook we rely upon ipvs for most of our layer-4 load balancing 
needs.  It's mostly worked pretty great for us.  The standard way to 
interact with ipvs is ipvsadm, which will use netlink sockets to make 
rpc calls to the kernel (things like adding/remove services and real 
servers).  Because we run many, many instances of ipvs, we ended up 
scripting this away with a separate program that shells out to ipvsadm.

The down side to this approach was that we had to format the arguments 
and parse the result of the tool, which was kind of a pain. 
Additionally, we'd sometimes get into a bad state where the exec would 
fail or the binary wouldn't be there and the whole thing would kind of 
break.  To my knowledge this never caused any kind of large scale 
incident, but it was an annoying thing to deal with.

At some point, we made some changes to ipvs (heterogenous pools) and we 
were in the position of needing to roll a new ipvsadm binary to take 
advantage of the functionality.  That was fundamentally unappealing to 
yours truly, so I hacked together gnlpy (Generic NetLink PYthon library) 
instead.  It's been in production for several months.

At some point thereafter, someone on the lvs-devel list mentioned 
wanting to interact with ipvs through python and I made a vague 
assurance that we'd open source this thing.  Well here we are.

If you take a look at the code, you'll quickly notice that we haven't 
gone through the trouble of implementing every RPC call for the families 
we support and we certainly haven't gone through the trouble of 
implementing every generic netlink family.  We welcome your pull requests :)

-- 
Alex Gartrell <agartrell@fb.com>
