From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 0/7] Support v6 real servers in v4 pools and vice
 versa
Date: Thu, 31 Jul 2014 07:00:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407310634580.1717@ja.home.ssi.bg>
References: <1406693455-915-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1407310028330.1826@ja.home.ssi.bg> <20140730190834.304a5085@agartrell-SH67H>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140730190834.304a5085@agartrell-SH67H>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Wed, 30 Jul 2014, Alex Gartrell wrote:

> Thanks for your review!
> 
> I've made most of the changes that you've asked for, just a couple
> quick questions before I submit v2.
> 
> 
> > 	This feature looks good to me.
> > 
> > 	Such change should go first in net-next tree, after the change
> > for skb->encapsulation (net tree). So, probably, after some -rc
> > we can add this patchset.
> >
> 
> SGTM
> 
> > 	So, to summarize our plan:
> > 
> > - we have sockopt and netlink interface
> > 
> > - IPv6 is supported only on netlink interface
> > 
> > - the sockopt structs can not be changed, eg.
> > struct ip_vs_dest_user in include/uapi/linux/ip_vs.h.
> > 
> > - ipvsadm should allow different family (svc and dest) only for TUN
> > method
> > 
> > - we can also encode somehow the tunnel mode in sync message, eg.
> > around the STYPE_F_INET6 value. May be this octet can become
> > tunnel/header type. This can be done later in another patchset.
> > 
> > 	Comments for your patchset:
> > 
> > Patch 1:
> > 	- please fix the dest->af = udest.af in __ip_vs_update_dest(),
> > 	so that this patch can compile and as result this fix will
> > 	disappear from patch 2:
> > 	-       dest->af = udest.af;
> > 	+       dest->af = udest->af;
> 
> Ah, embarrassing.  I thought I checked that this all compiled.  Will do.
> 
> > 	- __ip_vs_get_dest_entries() needs to skip dests with
> > 	dest->af != svc->af, we can not exports such dests to
> > 	sockopt users
> 
> Yeah seems reasonable, I'll include a short comment as well
> 
> > 	- too long comments, use scripts/checkpatch.pl
> > --strict /tmp/p1.diff
> 
> Another amateur move.  Thanks for the epointer
> 
> > 	- everything else looks ok
> > 
> > Patch 2:
> > 	- avoid error from patch 1 in __ip_vs_update_dest
> > 
> > 	- errors from scripts/checkpatch.pl --strict /tmp/p2.diff
> > 
> > Patch 3:
> > 	- in the "Destination %u/%s:%u still in trash, " message
> > 	we should use dest->af, not dest_af.
> > 
> > Patch 4:
> > 	- we have to introduce u16 cp->daf, just below cp->protocol
> 
> yeah makes sense
> 
> > 	- as result, cp->af is for caddr and vaddr, cp->daf is for
> > cp->daddr, this is needed because sync protocol can create connections
> > 	with cp->dest = NULL, cp binds to dest later
> 
> Agree that we should just create daf, but if we keep heterogeneous pools
> and sync distinct can we still run into this? (Just curious)

	I think, in patch 7 ip_vs_bind_xmit and ip_vs_bind_xmit_v6
will simply crash when sync is used, without heterogeneous pools,
due to cp->dest dereference. So, it happens for synced conns.

> > 	- ip_vs_ftp.c uses ip_vs_conn_new, now it does not compile
> 
> It appears that these are all IPv4 only, so I'll just use AF_INET and add a
> comment.

	Yes, ip_vs_ftp still supports v4 only.

> > 	- Another file net/netfilter/xt_ipvs.c depends on IPVS
> > 	definitions but I think this patchset does not break it
> >
> 
> Yeah, this still builds
> 
> > Patch 5:
> > 	- note that dest address can not be changed, so if you see
> > 	reason this patch to exist the check in __ip_vs_update_dest
> > 	should be: if (add && udest->af != svc->af)
> >
> 
> Well that definitely simplifies things.  My plan is to add a
> BUG_ON(!add && udest->af != dest->af) -- more as documentation than
> anything.

	The af,addr,port are the key we use to search dest,
it is silly to duplicate them as parameters just to support
such dest change, I think it can not happen.

> > 	- errors from scripts/checkpatch.pl --strict /tmp/p5.diff
> > 
> > Patch 6:
> > 	- comment and code do not match
> 
> What do you mean?  This just removes a temporary "return -EINVAL" to keep
> the code sane.

	This patch (6) changes only ip_vs_new_dest() but talks
about "sync" and "switch statement" ...

> > Patch 7:
> > 	- patch looks based on skb_checksum_help patch, the plan
> > 	is to base it after the offload change we are about to
> > 	send soon
> 
> Yeah, nothing significant about that, I was planning to rebase it the patch
> when it lands.

	I'll wait for comments about GSO for 1-2 days and will send
official patch.

> > 	- ip_vs_bind_xmit*: sync protocol does not guarantee that
> > 	cp->dest exists in all cases, we can not use cp->dest->af
> > 	because cp->dest can be NULL, we have to use cp->daf (from
> > 	patch 4)
> 
> Fixed this
> 
> > 
> > 	- for ip_vs_prepare_tunneled_skb():
> > 		- usage of 'version' can be changed to 'af'
> 
> I'm a little bit confused by this.  In this case, we aren't passing in af.
> Since the caller doesn't really know (or care) what the type of the packet
> is it made sense to figure it out from the ipheader version.  Do you mean
> that there's another function I should use to grab the address family from
> the skb or is it possible to get it from somewhere else?

	We can use cp->af, cp->dest can be NULL (synced conn)

> > 	- __ip_vs_get_out_rt_v6 and __ip_vs_get_out_rt should
> > 	be changed to account header from both families for MTU check,
> > 	these checks happen for IP_VS_RT_MODE_TUNNEL
> >
> 
> Yes this looks fairly significant.  Unless you'll object I'll introduce
> this as a separate patch.

	But in the same patchset, right?

> > 	- errors from scripts/checkpatch.pl --strict /tmp/p7.diff
> > 
> > - looking at cp, set_tcp_state() can not know what family is used for
> > 	cp->daddr, we have to use cp->daf. We have to check the
> > 	cp->af usage everywhere.
> > 
> > - I didn't fixed ip_vs_core.c logs yet
> > 
> > 	I'm attaching some patches for your patchset. If it is
> > difficult for you to maintain them in the patchset, we can post
> > them later after your patchset, as separate patchset. For now you
> > can use them as reference. Or may be they should be inserted
> > at some point in your patchset, so that your patchset looks
> > correct if applied up to some patch.
> 
> I'll add them to my patch set.  Thank you for doing them!

	Ok, thanks!

> > 	Let me know if you plan ipvsadm changes based on the
> > ipvsadm tree:
> >
> 
> I have made the appropriate changes for this.  It's a relatively
> straightforward patch.  I can submit it at any time.

	ok

Regards

--
Julian Anastasov <ja@ssi.bg>
