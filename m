From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2] ipvs: allow tunneling with gue encapsulation
Date: Sun, 17 Mar 2019 06:58:58 +0800
Message-ID: <201903170616.OmhwLbww%lkp@intel.com>
References: <20190316060635.2594-1-hengqing.hu@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190316060635.2594-1-hengqing.hu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, hengqing.hu@gmail.com, jacky.hu@walmart.com, jason.niesz@walmart.com, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Hi Jacky,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on ipvs-next/master]
[also build test WARNING on v5.0 next-20190306]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Jacky-Hu/ipvs-allow-tunneling-with-gue-encapsulation/20190317-042939
base:   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'


sparse warnings: (new ones prefixed by >>)

>> net/netfilter/ipvs/ip_vs_ctl.c:835:42: sparse: incorrect type in argument 2 (different base types) @@    expected int [signed] i @@    got restricted __be1int [signed] i @@
   net/netfilter/ipvs/ip_vs_ctl.c:835:42:    expected int [signed] i
   net/netfilter/ipvs/ip_vs_ctl.c:835:42:    got restricted __be16 [usertype] tun_port
   net/netfilter/ipvs/ip_vs_ctl.c:1175:44: sparse: expression using sizeof(void)
>> net/netfilter/ipvs/ip_vs_ctl.c:3329:41: sparse: incorrect type in assignment (different base types) @@    expected restricted __be16 [usertype] tun_port @@    got 16 [usertype] tun_port @@
   net/netfilter/ipvs/ip_vs_ctl.c:3329:41:    expected restricted __be16 [usertype] tun_port
   net/netfilter/ipvs/ip_vs_ctl.c:3329:41:    got unsigned short
   net/netfilter/ipvs/ip_vs_ctl.c:1291:27: sparse: dereference of noderef expression

vim +835 net/netfilter/ipvs/ip_vs_ctl.c

   805	
   806	/*
   807	 *	Update a destination in the given service
   808	 */
   809	static void
   810	__ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
   811			    struct ip_vs_dest_user_kern *udest, int add)
   812	{
   813		struct netns_ipvs *ipvs = svc->ipvs;
   814		struct ip_vs_service *old_svc;
   815		struct ip_vs_scheduler *sched;
   816		int conn_flags;
   817	
   818		/* We cannot modify an address and change the address family */
   819		BUG_ON(!add && udest->af != dest->af);
   820	
   821		if (add && udest->af != svc->af)
   822			ipvs->mixed_address_family_dests++;
   823	
   824		/* keep the last_weight with latest non-0 weight */
   825		if (add || udest->weight != 0)
   826			atomic_set(&dest->last_weight, udest->weight);
   827	
   828		/* set the weight and the flags */
   829		atomic_set(&dest->weight, udest->weight);
   830		conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
   831		conn_flags |= IP_VS_CONN_F_INACTIVE;
   832	
   833		/* set the tunnel info */
   834		atomic_set(&dest->tun_type, udest->tun_type);
 > 835		atomic_set(&dest->tun_port, udest->tun_port);
   836	
   837		/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
   838		if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
   839			conn_flags |= IP_VS_CONN_F_NOOUTPUT;
   840		} else {
   841			/*
   842			 *    Put the real service in rs_table if not present.
   843			 *    For now only for NAT!
   844			 */
   845			ip_vs_rs_hash(ipvs, dest);
   846			/* FTP-NAT requires conntrack for mangling */
   847			if (svc->port == FTPPORT)
   848				ip_vs_register_conntrack(svc);
   849		}
   850		atomic_set(&dest->conn_flags, conn_flags);
   851	
   852		/* bind the service */
   853		old_svc = rcu_dereference_protected(dest->svc, 1);
   854		if (!old_svc) {
   855			__ip_vs_bind_svc(dest, svc);
   856		} else {
   857			if (old_svc != svc) {
   858				ip_vs_zero_stats(&dest->stats);
   859				__ip_vs_bind_svc(dest, svc);
   860				__ip_vs_svc_put(old_svc, true);
   861			}
   862		}
   863	
   864		/* set the dest status flags */
   865		dest->flags |= IP_VS_DEST_F_AVAILABLE;
   866	
   867		if (udest->u_threshold == 0 || udest->u_threshold > dest->u_threshold)
   868			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
   869		dest->u_threshold = udest->u_threshold;
   870		dest->l_threshold = udest->l_threshold;
   871	
   872		dest->af = udest->af;
   873	
   874		spin_lock_bh(&dest->dst_lock);
   875		__ip_vs_dst_cache_reset(dest);
   876		spin_unlock_bh(&dest->dst_lock);
   877	
   878		if (add) {
   879			ip_vs_start_estimator(svc->ipvs, &dest->stats);
   880			list_add_rcu(&dest->n_list, &svc->destinations);
   881			svc->num_dests++;
   882			sched = rcu_dereference_protected(svc->scheduler, 1);
   883			if (sched && sched->add_dest)
   884				sched->add_dest(svc, dest);
   885		} else {
   886			sched = rcu_dereference_protected(svc->scheduler, 1);
   887			if (sched && sched->upd_dest)
   888				sched->upd_dest(svc, dest);
   889		}
   890	}
   891	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
