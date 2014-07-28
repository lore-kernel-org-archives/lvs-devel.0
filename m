From: Alex Gartrell <agartrell@fb.com>
Subject: What is the best way to accomplish "decapsulate any" functionality?
Date: Mon, 28 Jul 2014 11:26:32 -0700
Message-ID: <20140728112632.5f8e8f5f@agartrell-SH67H>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=date : from : to : cc :
 subject : message-id : mime-version : content-type :
 content-transfer-encoding; s=facebook;
 bh=lJK0NAEXhL0nG4POEayQ2u2ZzmjKBbB8ErB+pW9KZow=;
 b=hfCCQV32CiBzInx6pw2tdNi+fQp1zMTz49IyFBdNhPDPXYtN/osxN/eAMlFcKWMJ6Wxd
 GPj4y4DMq41mY73i9OytWlsaZnyaIKB9i4cI689OtbN3OitKCvgsXGUYyEG2Y3WOkVhJ
 BljkBfuHUVxuvV6XqMXKz8ezRoD/3qTbuk4= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: kernel-team@fb.com, ps@fb.com

Short Version:

What's the best way to accomplish "decapsulate any" functionality for
"IPv{4,6} in IPv{4,6}?"  Should I write an xfrm module or is there a
simple, existing method?

Long Version:

We've been using IPVS with ipip tunneling for ages, and it's been great,
but our decapsulation story has always been a little weak.  At some point,
someone figured out that if you create tunnel interfaces for both v4 and v6
and add loopback or link-local unicast addresses to each, the kernel will
magically start decapsulating these packets for you, and you can put your
virtual IPs on any dummy interface you want (or loopback).

So our load balancer's pre-run script basically boils down to:
ip tunnel add mode ipip
ip addr add dev tunl0 127.0.0.101/32
ip link set dev tunl0 up
ip addr add dev lo ${VIP}/32
# And then the equivalent for v6

And all was well and good in the kingdom.  But now we're getting ready to
turn up our IPv6-only internal cluster, and so we're forced to push forward
on things like v4-in-v6 tunneling (currently unsupported by IPVS, but we've
got a patch set that we'll put up when we have a working end-to-end-test).
Predictably, our magic script fell apart and we had to look into how the
sausage was made.

So, before I go off and write some terrible xfrm decapsulate-any module, is
there a "right way" to do this with stock linux?

Thanks,
Alex
