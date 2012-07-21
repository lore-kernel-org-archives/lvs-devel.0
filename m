From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Sat, 21 Jul 2012 07:09:36 +0200
Message-ID: <1342847376.2626.8162.camel@edumazet-glaptop>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	 <1342337165.3265.10640.camel@edumazet-glaptop>
	 <CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
	 <1342759989.2626.5472.camel@edumazet-glaptop>
	 <1342761865.2626.5572.camel@edumazet-glaptop>
	 <CABF+-6Ubh6rSYV=L8-QV466XNo5OqCxA+4DRqXGdELhnSPkPZQ@mail.gmail.com>
	 <CABF+-6XGO0Qvqd1O-aY28kG1jV=L6eRcupnZpaimTunddPwL2A@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=subject:from:to:cc:in-reply-to:references:content-type:date
         :message-id:mime-version:x-mailer:content-transfer-encoding;
        bh=INEEZz5jJ3aICJYbvmjIf3vk9D+Qdoqybi2PI35DaF0=;
        b=J93X8paMwTAG/fmcq+eUcaBcxFY16KRx+qZKP5NY/FJ1v7wLZAie4mWPjLpd09dOGB
         WFAjLVIu5UfcBLd8fudX+tdpJknEJw7ObukszY5K7Kj+h1AGVPAQI3Xx3h22iBGPJ71V
         SU5PG5hO3Gwvf64Jubwv54oOIFmpQBsU+EqzzFv7SJfDrtCjc3ye04OSKg7na2bPHOVg
         04NlHKNxtqtVi+xI36Rayd+lNVJNs7+3mpkF5wdt9GqHwBGNzIi8JT/4pPo7lE+QX7sO
         9H1KdJvBlkp71TdeozoSzM2/xNPo9BZ0RZGS+MRk2HWmxpjL6mxLEDChaEQHgs3fHMES
         5zaw==
In-Reply-To: <CABF+-6XGO0Qvqd1O-aY28kG1jV=L6eRcupnZpaimTunddPwL2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

On Fri, 2012-07-20 at 22:22 -0400, Kevin Groeneveld wrote:
> On Fri, Jul 20, 2012 at 2:56 PM, Kevin Groeneveld <kgroeneveld@gmail.com> wrote:
> >> In fact all network drivers should use the _bh version.
> >> Could you send a patch for all of them, based on net-next tree ?
> >
> > Sure, I can work on that.  It should be a relatively easy thing to
> > update.  I can probably send a patch within the next couple days.
> 
> As I have been working on the patch I have been trying convince myself
> that each case I change actually needs the _bh version of the
> functions instead of blindly changing them.  So far I have found the
> following where the change seems to make sense:
> 
> drivers/net/dummy.c
> drivers/net/ethernet/neterion/vxge/vxge-main.c
> drivers/net/loopback.c
> drivers/net/virtio_net.c
> net/bridge/br_device.c
> 

Thats right.

> The only two other places in the networking code that use
> u64_stats_fetch_begin/u64_stats_fetch_retry are:
> 
> net/l2tp/l2tp_netlink.c

This one is completely buggy, dont waste your time on it.

My plan for this one : dont try to have 64bit stats on 32bit arches, and
use plain "unsigned long" counters (if they are percpu), or
atomic_long_t (if they are shared by all cpus)

The writer sides might be run concurrently by several cpus, so
u64_stats_update_begin(&sstats->syncp); are racy : a reader can
be trapped forever.

> net/netfilter/ipvs/ip_vs_est.c
> 

Same problem for this one, I think.

I CCed ipvs maintainers so that they can take a look.

> Do these need to be updated as well?  Looking at these files quickly
> and with my limited knowledge of the kernel I am not sure if they
> update the stats in a BH context or not.
> 
> 
> Kevin

Thanks !

