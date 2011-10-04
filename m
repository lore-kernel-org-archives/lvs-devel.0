From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] IPVS netns shutdown/startup dead-lock (Take III)
Date: Wed, 5 Oct 2011 06:15:55 +0900
Message-ID: <20111004211554.GB11987@verge.net.au>
References: <1317711216-8416-1-git-send-email-hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1110041032520.1547@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1110041032520.1547@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Tue, Oct 04, 2011 at 10:40:29AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 4 Oct 2011, Hans Schillstrom wrote:
> 
> > From: Hans Schillstrom <hans@schillstrom.com>
> > 
> > ip_vs_mutext is used by both netns shutdown code and startup
> > and both implicit uses sk_lock-AF_INET mutex.
> > 
> > cleanup CPU-1         startup CPU-2
> > ip_vs_dst_event()     ip_vs_genl_set_cmd()
> >  sk_lock-AF_INET     __ip_vs_mutex
> >                      sk_lock-AF_INET
> > __ip_vs_mutex
> > * DEAD LOCK *
> > 
> > A new mutex placed in ip_vs netns struct called sync_mutex is added.
> > 
> > Comments from Julian and Simon added.
> > This patch has been running for more than 3 month now and it seems to work.
> > 
> > Ver. 3
> >     IP_VS_SO_GET_DAEMON in do_ip_vs_get_ctl protected by sync_mutex
> >     instead of __ip_vs_mutex as sugested by Julian.
> > 
> > Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> 
> 	Looks good to me, with one extra empty line in
> start_sync_thread
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I will apply this change.

