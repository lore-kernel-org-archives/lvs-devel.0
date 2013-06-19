From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/3] ipvs: replace the SCTP state machine
Date: Wed, 19 Jun 2013 07:49:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306190740080.1632@ja.ssi.bg>
References: <1371539288-5036-1-git-send-email-ja@ssi.bg> <1371539288-5036-3-git-send-email-ja@ssi.bg> <20130619005256.GA19345@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130619005256.GA19345@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Wed, 19 Jun 2013, Simon Horman wrote:

> On Tue, Jun 18, 2013 at 10:08:07AM +0300, Julian Anastasov wrote:
> > Convert the SCTP state table, so that it is more readable.
> > Change the states to be according to the diagram in RFC 2960
> > and add more states suitable for middle box. Still, such
> > change in states adds incompatibility if systems in sync
> > setup include this change and others do not include it.
> > 
> > With this change we also have proper transitions in INPUT-ONLY
> > mode (DR/TUN) where we see packets only from client. Now
> > we should not switch to 10-second CLOSED state at a time
> > when we should stay in ESTABLISHED state.
> > 
> > The short names for states are because we have 16-char space
> > in ipvsadm and 11-char limit for the connection list format.
> > It is a sequence of the TCP implementation where the longest
> > state name is ESTABLISHED.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Hi Julian,
> 
> I am having trouble applying the first ip_vs_proto_sctp.c hunk.
> 
> I have tried against net-next, nf-next and ipvs-next.
> Could you rebase it on the later and repost it with the second patch of
> this series?

	I forgot to mention that this patchset follows the
"ipvs: sloppy TCP and SCTP" change from Alexander Frolkin
posted on June 13. Our plans are for following list:

1. ipvs: sloppy TCP and SCTP (posted by Alexander and acked by me)
2. ipvs: provide iph to schedulers (just applied by you)
3. SH changes by Alexander (to be posted officially) depend
on 1 and 2 while SCTP patchset by me depends only on 1.
4. Changes to sync only persistent conns (only in my head - TODO)

	Let me know if you can apply (1) to -next before the
SCTP patchset (its patch 2+3), it does not collide with (2),
I think.

> I will take the first patch and see about getting it included in v3.10.

Regards

--
Julian Anastasov <ja@ssi.bg>
