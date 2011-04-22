From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 22 Apr 2011 17:19:27 +0200 (CEST)
Message-ID: <1pukl91.dee882dc58d0fe53f4e800b09c9f9eab@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

Hello Julian

From what I can see there is nothing in the rs_table except for NAT:ed dest, or ?
so the code fragment below will not work.

I.e. my double list_for_each that goes throug the service table must be there...
or do we need both?

[snip]
>
>- For ip_vs_dst_event: I prefer to put everything in this
>function, the ip_vs_svc_reset is not needed (name is not
>good too). For example:
>
>	struct ip_vs_dest *dest;
>	unsigned int hash;
>
>	mutex_lock(&__ip_vs_mutex);
>	/* No need to use rs_lock, the mutex protects the list */
>	for (hash = 0; hash < IP_VS_RTAB_SIZE; hash++) {
>		list_for_each_entry(dest, &ipvs->rs_table[hash], d_list) {
>			__ip_vs_dev_reset(dest, dev);
>		}
>	}
>
>	/* The mutex protects the trash list */
>	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
>		__ip_vs_dev_reset(dest, dev);
>	}
>
>	mutex_unlock(&__ip_vs_mutex);
>
>	No need to use __ip_vs_svc_lock or rs_lock because we
>do not change the lists, __ip_vs_dev_reset has the needed
>dst_cache locking (dst_lock). I assume we can safely use our
>__ip_vs_mutex from netdevice notifier.


Regards
Hans

