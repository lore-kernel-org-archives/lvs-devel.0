From: Julian Anastasov <ja@ssi.bg>
Subject: re: ipvs: Pull out crosses_local_route_boundary logic
Date: Wed, 1 Oct 2014 22:37:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1410012225530.3494@ja.home.ssi.bg>
References: <20141001174526.GA16206@mwanda>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20141001174526.GA16206@mwanda>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: agartrell@fb.com, lvs-devel@vger.kernel.org


	Hello,

On Wed, 1 Oct 2014, Dan Carpenter wrote:

> Hello Alex Gartrell,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 4a4739d56b00: "ipvs: Pull out crosses_local_route_boundary
> logic" from Sep 9, 2014, leads to the following Smatch complaint:
> 
> net/netfilter/ipvs/ip_vs_xmit.c:318 __ip_vs_get_out_rt()
> 	 error: we previously assumed 'dest' could be null (see line 312)
> 
> net/netfilter/ipvs/ip_vs_xmit.c
>    270          if (dest) {
>                     ^^^^
> Old check.
> 
>    271                  dest_dst = __ip_vs_dst_check(dest);
>    272                  if (likely(dest_dst))
>    273                          rt = (struct rtable *) dest_dst->dst_cache;
>    274                  else {
>    275                          dest_dst = ip_vs_dest_dst_alloc();
>    276                          spin_lock_bh(&dest->dst_lock);
>    277                          if (!dest_dst) {
>    278                                  __ip_vs_dst_set(dest, NULL, NULL, 0);
>    279                                  spin_unlock_bh(&dest->dst_lock);
>    280                                  goto err_unreach;
>    281                          }
>    282                          rt = do_output_route4(net, dest->addr.ip, rt_mode,
>    283                                                &dest_dst->dst_saddr.ip);
>    284                          if (!rt) {
>    285                                  __ip_vs_dst_set(dest, NULL, NULL, 0);
>    286                                  spin_unlock_bh(&dest->dst_lock);
>    287                                  ip_vs_dest_dst_free(dest_dst);
>    288                                  goto err_unreach;
>    289                          }
>    290                          __ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
>    291                          spin_unlock_bh(&dest->dst_lock);
>    292                          IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
>    293                                    &dest->addr.ip, &dest_dst->dst_saddr.ip,
>    294                                    atomic_read(&rt->dst.__refcnt));
>    295                  }
>    296                  daddr = dest->addr.ip;
>    297                  if (ret_saddr)
>    298                          *ret_saddr = dest_dst->dst_saddr.ip;
>    299          } else {
>    300                  __be32 saddr = htonl(INADDR_ANY);
>    301  
>    302                  noref = 0;
>    303  
>    304                  /* For such unconfigured boxes avoid many route lookups
>    305                   * for performance reasons because we do not remember saddr
>    306                   */
>    307                  rt_mode &= ~IP_VS_RT_MODE_CONNECT;
>    308                  rt = do_output_route4(net, daddr, rt_mode, &saddr);
>    309                  if (!rt)
>    310                          goto err_unreach;
>    311			if (ret_saddr)
>    312				*ret_saddr = saddr;
>    313		}
>    314	
>    315		local = (rt->rt_flags & RTCF_LOCAL) ? 1 : 0;
>    316		if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
>    317							  local))) {
>    318			IP_VS_DBG_RL("We are crossing local and non-local addresses"
>    319				     " daddr=%pI4\n", &dest->addr.ip);
>                                                        ^^^^^^^^^^^^^

	Good catch. In fact, I requested Alex to print
daddr in this case but then we both missed this dest here...
Alex, both v4 (&daddr) and v6 (daddr) should be fixed.

> New unchecked dereference.
> 
>    320			goto err_put;
> 
> Also:
> net/netfilter/ipvs/ip_vs_xmit.c:460 __ip_vs_get_out_rt_v6() error: we previously assumed 'dest' could be null (see line 415)
> 
> regards,
> dan carpenter

Regards

--
Julian Anastasov <ja@ssi.bg>
