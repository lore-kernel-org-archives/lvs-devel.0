From: Julian Anastasov <ja@ssi.bg>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Tue, 15 Apr 2008 02:16:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804150127400.3092@u.domain.uli>
References: <200804111400.12331.j.stubbs@linkthink.co.jp>
 <Pine.LNX.4.58.0804121021110.2942@u.domain.uli> <200804142004.39881.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804142004.39881.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: LVS Devel <lvs-devel@vger.kernel.org>


	Hello,

On Mon, 14 Apr 2008, Jason Stubbs wrote:

> > > * IP_VS_CONN_F_BYPASS - what is this?
> >
> > 	IP_VS_CONN_F_BYPASS is used for transparent proxy setups when
> > real server (cache server) is not present and we should forward the
> > traffic to original destination. The idea is request still to be served.
> > In such case IPVS traffic uses the original destination instead of real
> > server.
> 
> Not tested yet. I assume I just need to add a real server with the same 
> IP/port as the virtual server?

	Not sure, may be IP:PORT of LVS's uplink gateway. In such
setups clients are usually internal hosts using LVS box as gateway.

> > - Netfilter can re-route sometimes (eg. after mangle), it can cause
> > properly routed LVS-DR traffic to fail.
> 
> I don't understand exactly what you mean by this. It could only happen if the 
> user sets rules that causes it to happen right?

	May be the things have changed, not sure. The problem is when
functions like ip_route_me_harder() are called for packets that
are already forwarded by IPVS (skb has attached route for the
real server). In such case skb still shows VIP as iph->daddr and
a rerouting can result in local route. But latest kernels may be
reroute only in LOCAL_OUT, so this is not a problem.

	As for the double POST_ROUTING log entries ... I'm checking
this NF_HOOK_THRESH call with NF_IP_PRI_LAST. For me, it looks like
net/netfilter/core.c:nf_iterate() calls only handlers when
elem->priority >= hook_thresh. But you put ip_vs_in() at the same
priority NF_IP_PRI_LAST. May be ip_vs_in() is called twice?

	Also, if ip_vs_in() is called  after SNAT I'm curious, isn't 
ip_vs_ftp working with DNAT-ed skb (if you have netfilter ftp nat
module) ? May be things don't break because IPVS is careful not to
damage packets it can not recognize. But do we work properly with
the FTP commands in ip_vs_ftp_in(), do we create properly FTP data 
connections in IPVS? I assume you test both passive and active FTP.
If the goal is -m state to work correctly, are you sure the IPVS FTP
data connections work correctly (as RELATED traffic)?

Regards

--
Julian Anastasov <ja@ssi.bg>
