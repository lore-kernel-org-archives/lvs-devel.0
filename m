From: Julian Anastasov <ja@ssi.bg>
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count
 = 8
Date: Tue, 19 Apr 2011 01:23:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104190112500.1481@ja.ssi.bg>
References: <201104150901.47214.hans@schillstrom.com> <201104181243.30613.hans@schillstrom.com> <alpine.LFD.2.00.1104182316060.1481@ja.ssi.bg> <201104182348.05228.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201104182348.05228.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>


	Hello,

On Mon, 18 Apr 2011, Hans Schillstrom wrote:

> On Monday, April 18, 2011 23:12:27 Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Mon, 18 Apr 2011, Hans Schillstrom wrote:
> > 
> > > Actually I forgot to tell there is a need for a
> > > ip_vs_service_cleanup() due to above.
> > > Do you see any drawbacks with it ?
> > 
> > 	May be ip_vs_service_cleanup() should call only
> > ip_vs_flush(), under __ip_vs_mutex.
> 
> Hmm,  
> I'm not sure if the IP_VS_WAIT_WHILE() in ip_vs_flush is a good idea in this case...
> That was why I wrote ip_vs_service_cleanup()

	IP_VS_WAIT_WHILE should be called because some
schedulers do not use locks for ->schedule, eg. WLC.
They rely on svc->usecnt reference to hold the virtual
service. Nothing changes now with netns. It is currently the
only way to modify or delete virtual service or scheduler.
Of course, __ip_vs_svc_lock is now global but we do not
have a choice.

> > _cleanup_net. Now there are many register_pernet_subsys()
> > calls and I'm not sure we preserve the needed order for
> > cleanup. Are the ->exit methods called in reverse order?
> 
> Yes

	You mean, only in the planned patch, yes?

> > I don't see it in ops_exit_list() and we can not rely
> > on such registration order. I think, ip_vs_init() should
> > call global functions as now but __ip_vs_init() and
> > __ip_vs_cleanup() should call the _net methods in right
> > order.
> 
> Exactly,
> I have already done that in my next patch,  and some other small changes :-)
> For the ip_vs.ko there is only one register/unregister now, the schedulers still have their own.
> Hopefully the patch is ready to morrow

	OK, very good.

Regards

--
Julian Anastasov <ja@ssi.bg>
