From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 30 May 2013 09:37:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305300830100.1671@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51A4B3ED.4070809@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 28 May 2013, Aleksey Chudov wrote:

> On 28.05.2013 0:31, Julian Anastasov wrote:
> > On Fri, 24 May 2013, Aleksey Chudov wrote:
> > 
> > > May be better to modify the sync algorithm to synchronize only persistence
> > > templates for these specific cases? Is it possible at all?
> > 	May be, with some flag and also sloppy_tcp. Then the
> > parametrized SH with netmask will do the same - we can avoid
> > the sync messages. Of course, with SH there is more risk
> > for imbalance and it can be exploited. Also SH requires
> > equal configuration for the real servers.
> > 
> 
> Currently we are using multiple active / standby server pairs and synchronize
> them with each other. So half of the servers are constantly doing nothing. We
> are searching how to use all the servers in active / active mode while
> maintaining high availability and sessions persistence in case of failure of
> one of the load balancers. Unfortunately the proposed stateless scheme with SH
> scheduler and Sloppy TCP is not suitable for as since we are using WLC and WRR
> schedulers. As you mentioned SH scheduler has several drawbacks because of
> which we can not use it. Also, we can not synchronize all connections between
> all servers, since it would require a lot of memory and the search for such a
> huge connection table is likely to be slower.
> 
> But we can solve the sync problem in such a way as done in the conntrackd
> which allows filtering by flow state. The easiest option is to make the filter
> only for IP_VS_CONN_F_TEMPLATE state. Thus if all the load balancers will sync
> persistent templates with each other then even if one of the load balancers
> fails most users will remain on the same real servers. Of course without the
> full sync clients must reestablish TCP connections, but for this case we can
> use Sloppy TCP to create a TCP connection state on any TCP packet.
> 
> What do you think of this idea?

	Agreed, if we don't find big problems with the
Sloppy TCP mode the only problem will be what happens with
netfilter conntracks. But it is a problem even now, even
if we create sync conn in backup, we do not provide any
information to netfilter about such connection and it
would be expected to see packets in INVALID state.

	Looking at the code I don't see problems
Sloppy TCP mode to be enabled, ip_vs_out is called
before ip_vs_in in every hook, so there is no chance
to create connection in a wrong direction. Of course,
we have to do some tests, especially on loopback device.

	May be the patch for Sloppy TCP mode should be
extended to assume that old state is sSR if packet that
creates the connection has no RST flag. This will allow
connection to enter sES state if need, it will not stay
always in sCL state. As for the initial check, it should be:

	if ((sysctl_sloppy_tcp(net_ipvs(net)) || th->syn) &&
+	    !th->rst &&

	Also, one can enable Sloppy TCP mode for short
time during switchover, it should be safer to run with
disabled mode.

Regards

--
Julian Anastasov <ja@ssi.bg>
