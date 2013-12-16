From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: avoid oops in nf_ct_seqadj_set when called from
 ip_vs_ftp helper
Date: Mon, 16 Dec 2013 23:05:48 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1312162247030.2063@ja.home.ssi.bg>
References: <20131213214023.14478.74738.stgit@dragon> <alpine.LFD.2.11.1312151709260.6463@ja.home.ssi.bg> <20131216155724.2a174830@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131216155724.2a174830@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>


	Hello,

On Mon, 16 Dec 2013, Jesper Dangaard Brouer wrote:

> On Sun, 15 Dec 2013 18:10:42 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:

> > @@ -260,7 +261,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  		buf_len = strlen(buf);
> >  
> >  		ct = nf_ct_get(skb, &ctinfo);
> > -		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
> > +		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct) &&
> > +		    nfct_seqadj(ct)) {
> 
> If we add the other section, then this check should not be necessary.

	In the common case - yes. nfct_seqadj_ext_add needs
to be called before confirmation, that is why we place it
in ip_vs_update_conntrack(). There is another case when
synced connection comes to backup in established state.
I'm not sure what happens in netfilter in this case, we
do not provide any initial seq and offsets to be used by
the seqadj code. We have to think more about this case.

	So, we need nfct_seqadj check in ip_vs_ftp_out or in
nf_ct_seqadj_set as in your patch 1/2 to avoid oops for
synced connections.

> > +	/* Applications may adjust TCP seqs */
> > +	if (cp->app && nf_ct_protonum(ct) == IPPROTO_TCP &&
> > +	    !nfct_seqadj(ct) && !nfct_seqadj_ext_add(ct))
> > +		return;
> > +
> 
> It will work.
> 
> I'm just thinking if we will allocate a seqadj ext, in too many
> situations, were its not really needed... double checking, I see that
> "cp->app" will limit us a lot, as it seems that FTP is the only one
> using register_ip_vs_app(),

	Yes. And we can not do it just before nf_nat_mangle_tcp_packet,
it should happen before conntrack is confirmed, on SYN.

> And above this, we do check:
> 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> 		return;
> So, we only do this for IPVS masq case, good.
> I think we are good.
> 
> Now, I'm just wondering if SIP will work... (but I don't have a lab to
> test this).

	It is only for UDP, for now...

Regards

--
Julian Anastasov <ja@ssi.bg>
