From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 22 Apr 2011 19:49:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104221945340.1550@ja.ssi.bg>
References: <1pukl91.dee882dc58d0fe53f4e800b09c9f9eab@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1pukl91.dee882dc58d0fe53f4e800b09c9f9eab@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com


	Hello,

On Fri, 22 Apr 2011, Hans Schillstrom wrote:

> Hello Julian
> 
> >From what I can see there is nothing in the rs_table except for NAT:ed dest, or ?
> so the code fragment below will not work.
> 
> I.e. my double list_for_each that goes throug the service table must be there...
> or do we need both?

	Yes, I now see that dests are added to rs_table only for
NAT. So, we have no choice, we have to walk svc->destinations.
To remove usage of dest_trash in ip_vs_dst_event we can move
the ip_vs_dst_reset call in __ip_vs_del_dest() above the
atomic_dec_and_test check. But it is not a safe operation.
While with svc->usecnt we know if packet accesses the svc,
the same for dest is not possible. Packet can hit existing
connection (without searching for svc), conn has reference to
dest, so the packet can refresh dest->dst_cache at any point
of time, eg. while we move dest to trash. That is why
__ip_vs_del_dest calls ip_vs_dst_reset only when dest->refcnt
reaches 0, i.e. when no conn refers to dest. So, even if we
call ip_vs_dst_reset() before the atomic_dec_and_test check,
it is still possible some packet to attach new dst_cache
entry. As result, we can not assume that dests in trash have
no dst_cache entry. So, ip_vs_dst_event() needs to walk
both svc->destinations and ipvs->dest_trash under mutex lock.

Regards

--
Julian Anastasov <ja@ssi.bg>
