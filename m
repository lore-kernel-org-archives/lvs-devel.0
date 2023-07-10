From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table
 per netns
Date: Mon, 10 Jul 2023 20:30:34 +0300 (EEST)
Message-ID: <3d37360e-846a-3b01-f2ad-9c1c5720a568@ssi.bg>
References: <20230707020708.75168-1-dust.li@linux.alibaba.com> <28a87ee9-5f94-2506-3cb9-8a19144e2061@ssi.bg> <20230710152809.GD6751@linux.alibaba.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1689010240; bh=GTzycfPTuL6xYhwrHAUqSMOXS9y7swYh/taQTI/rhUo=;
        h=Date:From:To:cc:Subject:In-Reply-To:References;
        b=o+Pqd5sLAlDt8AtdXenR/ZT1D2AWctaPbUeBWEAqkXC277L3wKh8qIR5/cvopEjSx
         hd1gczybHTnm13BnmtgUTSJVA1FcgYkLuqscDKNjNxWmLxCsa2AuEGPFC/iQ/r3ysR
         WT6rOpnXNWqqPyl/GuJD13mSWkL/7J/Pc38M4X/A=
In-Reply-To: <20230710152809.GD6751@linux.alibaba.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dust Li <dust.li@linux.alibaba.com>
Cc: Jiejian Wu <jiejian@linux.alibaba.com>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Mon, 10 Jul 2023, Dust Li wrote:

> On Sun, Jul 09, 2023 at 08:45:19PM +0300, Julian Anastasov wrote:
> >
> >	Hello,
> >
> >On Fri, 7 Jul 2023, Dust Li wrote:
> >
> >> @@ -2303,9 +2293,9 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
> >>  
> >>  	/* look in hash by protocol */
> >>  	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
> >> -		hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[idx], s_list) {
> >> +		hlist_for_each_entry_rcu(svc, &ipvs->ip_vs_svc_table[idx], s_list) {
> >>  			if ((svc->ipvs == ipvs) && pos-- == 0) {
> >> -				iter->table = ip_vs_svc_table;
> >> +				iter->table = ipvs->ip_vs_svc_table;
> >
> >	We can change iter->table to int table_id, 0 (ip_vs_svc_table)
> >and 1 (ip_vs_svc_fwm_table), for all these ip_vs_info_* funcs.
> 
> Sorry, I don't get this. Why do we need to change this ?

	It is a hint which table to walk, no need for such
dereferences. For example:

	iter->table = ip_vs_svc_table;
	becomes
	iter->table_id = 0;

	iter->table = ip_vs_svc_fwm_table;
	becomes
	iter->table_id = 1;

	etc

> >> @@ -3392,9 +3384,9 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
> >>  	struct net *net = sock_net(skb->sk);
> >>  	struct netns_ipvs *ipvs = net_ipvs(net);
> >>  
> >> -	mutex_lock(&__ip_vs_mutex);
> >> +	mutex_lock(&ipvs->service_mutex);
> >
> >	While do_ip_vs_get_ctl is a reader that can block we
> >can not use RCU but in ip_vs_genl_dump_services() we can replace
> >the __ip_vs_mutex with rcu_read_lock because we just fill the skb.
> >
> 
> I think we can replace mutex in ip_vs_genl_dump_services() by RCU.
> Do you prefer replacing it in this patch or later ?

	You can include these RCU conversions

> >	Also, there is more work if we want independent
> >namespaces and to give power to users:
> >
> >- account memory: GFP_KERNEL -> GFP_KERNEL_ACCOUNT
> >
> >- the connections table is still global but it should be possible
> >to make all tables per-net and to grow on load from NULL to max bits
> >
> >- convert GENL_ADMIN_PERM -> GENL_UNS_ADMIN_PERM and make
> >sysctls visible to other namespaces
> >
> >	If the plan is to have multiple netns loaded with many
> >conns may be I can follow your patch with more optimization
> >patches.
> 
> Yes, we do missed those details. I think moving those into different
> netns is good, besides we already have netns supported. So why not do
> it more completely ?
> 
> If it is convenient for you to do more optimizations, we would greatly
> appreciate it !

	Yes, I'll prepare more patches on top of your patch.

Regards

--
Julian Anastasov <ja@ssi.bg>

