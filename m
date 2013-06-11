From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 11 Jun 2013 22:57:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg> <20130607081252.GC11902@eldamar.org.uk> <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130611083806.GA25531@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 11 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> > > Is there a reason why the SH fallback behaviour shouldn't be default?
> > > That is, is there a reason why the current behaviour (client connection
> > > gets reset if it is directed to a realserver with weight 0) is
> > > desirable?
> > I don't know, the authors preferred this behaviour.
> 
> Is it worth looking at changing this?  Or is this going to be too
> difficult a change to push through?

	I'm not sure how SH is used, may be failed
dests are removed from the list to avoid connection
failures.

> I just don't understand why rejecting a client connection when there are
> servers available is desirable behaviour.

	The problem is that every move leads to problems:

- add/remove destination => mapping is changed for all dests

- set weight to 0 and allow fallback => mapping is changed for
	two connections from same IP

	As result, it is a bad idea to remove dests that are
failed. In such case, without fallback some clients are not
served, forever. But with fallback we can break the
implicit persistence. I see two kinds of uses:

- persistence implemented with SH => fallback is risky. Usually,
we use expire_quiescent_template for such cases when persistence
is used.

- same mapping for many directors => fallback is desired when
config is same on all directors and persistence behaviour is
not desired.

	So, it really depends what are our goals when using SH.
Not sure if we can apply the expire_quiescent_template flag to
the SH scheduler to control fallback.

Regards

--
Julian Anastasov <ja@ssi.bg>
