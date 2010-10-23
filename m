From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [rfc v2 00/10] ipvs network name space (netns) aware
Date: Sat, 23 Oct 2010 10:44:31 +0200
Message-ID: <201010231044.32503.hans@schillstrom.com>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Daniel Lezcano <daniel.lezcano@free.fr>, Wensong Zhang <wensong@linux-vs.org>

Hi Simon
Thanx a lot. for your work, I will use this a the new base

On Friday, October 22, 2010 22:09:34 Simon Horman wrote:
> Hi Hans,
> 
> this is a re-base of your patch-set against the current nf-next-2.6 tree,
> which includes all the changes currently queued for 2.6.37-rc1 and nothing
> else.
> 
> I also removed the BUG_ON() statements and incorported various
> suggestions that were made in response to your original post.
> 
> It is compile tested only (partly because I am in an areoplane).
> 
> I have not re-split the patches into logical units.
> Having worked with these patches a bit, I really think
> that split needs to occur.

Daniel  will help me with that, i.e. we will split the work between us.
The plan is to do it in small steps

> 
> For the benefit of others, your original cover email is below,
> updated as appropriate.
> 
> -----
> 
> This patch series adds network name space (netns) support to the LVS.
> 
> REVISION
> 
> This is version 2
> 
> OVERVIEW
> 
> The patch doesn't remove or add any functionality except for netns.
> For users that don't use network name space (netns) this patch is
> completely transparent.
> 
> No it's possible to run LVS in a Linux container (see lxc-tools)
> i.e.  a light weight virtualization. For example it's possible to run
> one or several lvs on a real server in their own network name spaces.
> >From the LVS point of view it looks like it runs on it's own machine.
> 
> IMPLEMENTATION
> Basic requirements for netns awareness
>  - Global variables has to be moved to dyn. allocated memory.
> 
> Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
> What is moved and what is not ?
> 
> Some cache aligned locks are still in global, module init params and some debug_level.
> 
> Algorithm files they are untouched.
> 
> QUESTIONS
> Drop rate in ip_vs_ctl per netns or grand total ?
> Should more lock variables be moved (or less) ?
> 
> Include files,
> A new file added include/net/netns/ip_vs.h containg all netns specific data.
> include/net/net_namespce.h, pointer to "struct ipvs"  added.
> include/net/ip_vs.h a new struct added, and many prototypes changed.
> 
> * ip_vs_core.c
> All netns init origins from this file - ip_vs_init()
> 
> * ip_vs_conn.c
> Lock array for conn table is kept due to performance,
> (or am I wrong here ?).
> "static struct ip_vs_aligned_lock
> __ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;"
> 
> * ip_vs_ctl.c
> drop_ rate is still global
> 
> TESTING
> This patch have been running for a month now with three LVS/machine
> one in root name-space and two in other name-space.
> Both IPv4 & IPv6 have been tested in all three modes DR/TUN and NAT
> Only a limited set of algos have been used (read rr).
> 
> Backup have been there all the time and a switch has been performed a couple of times.
> 
> Not tested yet:
>  Drop level, DOS,  schedulers, performance ....
>  Netns exit after usage of LVS (due to a bug in netdev/ipip somewhere tunl0 and
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
-- 
Mvh
Hasse Schillstrom <hans@schillstrom.com>

