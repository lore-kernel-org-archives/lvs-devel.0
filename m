From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Multiple load balancers problem
Date: Tue, 28 Aug 2012 10:21:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208281013570.1693@ja.ssi.bg>
References: <503880A4.6000801@stalker.com> <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg> <503B2982.7010507@stalker.com> <alpine.LFD.2.00.1208271313420.1934@ja.ssi.bg> <503B8EF6.5040609@stalker.com> <alpine.LFD.2.00.1208271832460.24809@ja.ssi.bg>
 <503BD786.9020604@stalker.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <503BD786.9020604@stalker.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Akindinov <dimak@stalker.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 28 Aug 2012, Dmitry Akindinov wrote:

> > 	No loop? Because S2 will receive DR method in
> > the SYNC messages for its stack. You see traffic flow
> > or just that there is no reset?
> 
> Yes, after the failover, all connections that were open on the S2 (which now
> becomes the active balancer) do not reset and continue to function just fine
> (traffic flow in both directions).

	Aha, I now see why, ip_vs_bind_dest assigns the
forwarding mode from real server, not from SYNC messages.
As you have LOCALNODE when S2 is slave, the DR mode from
SYNC message is not used, that is why after failover the
S2 connections work and are not reset. So, at least, we have
explanation for all things that happen. If you run slave
without any rules the connection will use the mode from
master and you will see packet loop.

> -- 
> Best regards,
> Dmitry Akindinov

Regards

--
Julian Anastasov <ja@ssi.bg>
