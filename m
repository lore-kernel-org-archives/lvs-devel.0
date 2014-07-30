From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 0/7] Support v6 real servers in v4 pools and vice
 versa
Date: Thu, 31 Jul 2014 00:32:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407310028330.1826@ja.home.ssi.bg>
References: <1406693455-915-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1041091654-1406755992=:1826"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1406693455-915-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1041091654-1406755992=:1826
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

On Tue, 29 Jul 2014, Alex Gartrell wrote:

> At Facebook we use ipip forwarding to deliver packets from our layer 4 ipvs
> load balancers to our layer 7 proxies.  Today these layer 7 proxies are all
> dual stacked, so we can simply send v4 over v4 and v6 over v6.  In the
> future, we're going to have v6-only layer 7 load balancers (no internal v4
> address).  To deal with this, we'll forward v4 packets in v6 tunnels.  This
> patchset introduces the necessary functionality into ipvs.
> 
> The noteworthy limitation of this is that it is not compatible with state
> synchronization, so great care is taken to keep these things mutually
> exclusive.
> 
> This patchset includes changes that add an additional netlink attribute to
> destinations and changes that plumb the destination address family through
> parts of the code where it was assumed that it was the same as the service.
> Finally, there's a change that updates the transmit functions for tunneling
> to share common code and support v4 in v6 and vice versa.
> 
> Alex Gartrell (7):
>   ipvs: Add destination address family to netlink interface
>   ipvs: Supply destination addr family to ip_vs_{lookup_dest,find_dest}
>   ipvs: Pass destination address family to ip_vs_trash_get_dest
>   ipvs: Supply destination address family to ip_vs_conn_new
>   ipvs: maintain a mixed_address_family_dest count
>   ipvs: prevent mixing heterogeneous pools and synchronization
>   ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding

	This feature looks good to me.

	Such change should go first in net-next tree, after the change
for skb->encapsulation (net tree). So, probably, after some -rc
we can add this patchset.

	So, to summarize our plan:

- we have sockopt and netlink interface

- IPv6 is supported only on netlink interface

- the sockopt structs can not be changed, eg.
struct ip_vs_dest_user in include/uapi/linux/ip_vs.h.

- ipvsadm should allow different family (svc and dest) only for TUN method

- we can also encode somehow the tunnel mode in sync message, eg.
around the STYPE_F_INET6 value. May be this octet can become
tunnel/header type. This can be done later in another patchset.

	Comments for your patchset:

Patch 1:
	- please fix the dest->af = udest.af in __ip_vs_update_dest(),
	so that this patch can compile and as result this fix will
	disappear from patch 2:
	-       dest->af = udest.af;
	+       dest->af = udest->af;

	- __ip_vs_get_dest_entries() needs to skip dests with
	dest->af != svc->af, we can not exports such dests to
	sockopt users

	- too long comments, use scripts/checkpatch.pl --strict /tmp/p1.diff

	- everything else looks ok

Patch 2:
	- avoid error from patch 1 in __ip_vs_update_dest

	- errors from scripts/checkpatch.pl --strict /tmp/p2.diff

Patch 3:
	- in the "Destination %u/%s:%u still in trash, " message
	we should use dest->af, not dest_af.

Patch 4:
	- we have to introduce u16 cp->daf, just below cp->protocol

	- as result, cp->af is for caddr and vaddr, cp->daf is for cp->daddr,
	this is needed because sync protocol can create connections
	with cp->dest = NULL, cp binds to dest later

	- ip_vs_ftp.c uses ip_vs_conn_new, now it does not compile

	- Another file net/netfilter/xt_ipvs.c depends on IPVS
	definitions but I think this patchset does not break it

Patch 5:
	- note that dest address can not be changed, so if you see
	reason this patch to exist the check in __ip_vs_update_dest
	should be: if (add && udest->af != svc->af)

	- errors from scripts/checkpatch.pl --strict /tmp/p5.diff

Patch 6:
	- comment and code do not match

Patch 7:
	- patch looks based on skb_checksum_help patch, the plan
	is to base it after the offload change we are about to
	send soon

	- ip_vs_bind_xmit*: sync protocol does not guarantee that
	cp->dest exists in all cases, we can not use cp->dest->af
	because cp->dest can be NULL, we have to use cp->daf (from
	patch 4)

	- for ip_vs_prepare_tunneled_skb():
		- usage of 'version' can be changed to 'af'

	- __ip_vs_get_out_rt_v6 and __ip_vs_get_out_rt should
	be changed to account header from both families for MTU check,
	these checks happen for IP_VS_RT_MODE_TUNNEL

	- errors from scripts/checkpatch.pl --strict /tmp/p7.diff

- looking at cp, set_tcp_state() can not know what family is used for
	cp->daddr, we have to use cp->daf. We have to check the
	cp->af usage everywhere.

- I didn't fixed ip_vs_core.c logs yet

	I'm attaching some patches for your patchset. If it is
difficult for you to maintain them in the patchset, we can post
them later after your patchset, as separate patchset. For now you
can use them as reference. Or may be they should be inserted
at some point in your patchset, so that your patchset looks
correct if applied up to some patch.

	Let me know if you plan ipvsadm changes based on the
ipvsadm tree:

git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

	I can do it, if needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1041091654-1406755992=:1826
Content-Type: APPLICATION/gzip; name=af.tgz
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.LFD.2.11.1407310032580.1826@ja.home.ssi.bg>
Content-Description: AF patches
Content-Disposition: attachment; filename=af.tgz

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

---1463811672-1041091654-1406755992=:1826--
