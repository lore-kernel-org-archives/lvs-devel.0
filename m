From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH next 00/84] ipvs: Stop guessing the network namespace
Date: Sun, 20 Sep 2015 11:41:20 -0500
Message-ID: <87si69jb67.fsf@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org>
	<87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
	<87h9mplifu.fsf_-_@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1509201719370.4441@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1509201719370.4441@ja.home.ssi.bg> (Julian
	Anastasov's message of "Sun, 20 Sep 2015 17:38:32 +0300 (EEST)")
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
>
> 	I reviewed the patchset. Nice work, thanks!

Welcome.

> Here are some comments:
>
> 01/84 ipvs: Hoist computation of ipvs earlier in sctp_conn_schedule
>
> 	Simon had a fix for this problem, not sure what happened,
> may be it was lost...
>
> 04/84 ipvs: Store ipvs not net in struct ip_vs_conn
>
> 	Lost '!' here:

Very good catch thank you.

> @@ -359,7 +359,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct
> ip_vs_conn_param *p)
>  
>         hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
>                 if (unlikely(p->pe_data && p->pe->ct_match)) {
> -                       if (!ip_vs_conn_net_eq(cp, p->net))
> +                       if (net_eq(cp->ipvs->net, p->net))
>                                 continue;
>
> 	Problem is then propagated to patch 05/84:
>
> -                       if (net_eq(cp->ipvs->net, p->net))
> +                       if (cp->ipvs == p->ipvs)
>
> 26/84 ipvs: Pass ipvs not net to __ip_vs_get_servie_entries
>
> 	Missing 'c' in Subject
>
> 55/84 ipvs: Pass ipvs not net to register_ip_vs_app and 
> unregister_ip_vs_app
>
> 	Empty line after ipvs declaration:
>
>  void __net_exit ip_vs_app_net_cleanup(struct net *net)
>  {
> -       unregister_ip_vs_app(net, NULL /* all */);
> +       struct netns_ipvs *ipvs = net_ipvs(net);
> +       unregister_ip_vs_app(ipvs, NULL /* all */);
>
> 	here too:
>
>  static void __ip_vs_ftp_exit(struct net *net)
>  {
> -       unregister_ip_vs_app(net, &ip_vs_ftp);
> +       struct netns_ipvs *ipvs = net_ipvs(net);
> +       if (!ipvs)
>
> 61/84 ipvs: Pass ipvs into .conn_in_get and ip_vs_conn_in_get_proto
>
> 	"dreive"
>
> 62/84 ipvs: Pass ipvs into conn_out_get
>
> 	"dreive"

I have fixed the above, and pushed the changes into my git tree.
I will resend the patchset tomorrow if nothing else shows up.

> 	Also, scripts/checkpatch.pl --strict /tmp/*.patch gives
> me warnings, sometimes for inherited syntax...

I looked and I have fixed one or two of those, but mostly inherited
syntax and lines too long I am not tocuhing.  The odds of introducing
or obscuring an error right now far outweigh the odds of making
something better.

Eric
