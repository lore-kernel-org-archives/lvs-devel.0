From: Julian Anastasov <ja@ssi.bg>
Subject: Re[2]:  [PATCH 2/2] ipvs: fix app registration in netns
Date: Sat, 14 Apr 2012 00:29:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204140014300.12601@ja.ssi.bg>
References: <6dfqp4f.13413aadaead24bb8e0685fc27648dc7@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <6dfqp4f.13413aadaead24bb8e0685fc27648dc7@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>


	Hello,

On Fri, 13 Apr 2012, Hans Schillstrom wrote:

> >> I think we can do this much simpler,
> >> remove the auto init of ftp (ip_vs_ftp_init and ip_vs_ftp_exit) 
> >> and let ip_vs_app call __ip_vs_ftp_init() as a we do with the protocols.
> >> 
> >> If the init fails before ip_vs_app_net_init() ftp init will not be called
> >> and if it fails after a proper cleanup will be performed.
> >> 
> >> i.e. same design every where.
> >> 
> >> ex remove the
> >>  ip_vs_ftp_init(void)
> >>  ip_vs_ftp_exit(void)
> >
> >	OK, go ahead. But also change init_netns for
> >proto (and now for apps) to return int error. Now
> >__ip_vs_tcp_init does not return error if the
> >pd->timeout_table allocation fails. This is fatal.
> >
> >	May be you can do this change on top of these
> >two patches because init_netns for ftp should be NULL,
> >we do not need to allocate anything for netns. Only
> >&ip_vs_ftp should go in some new global list to be cloned
> >for every netns as my 2nd patch:
> 
> OK I can take care of this, but not before Sunday evening 

	You say it is simple but I'm not sure :)
If things look complicated you do not need to do it.
Note that apps and schedulers are loaded after core,
so their netns handlers are always called after the
handlers of ip_vs_core. It works in both ways:
with init_netns handler or with their own pernet
subsys.

	Currently, __ip_vs_ftp_init has the freedom
to call register_ip_vs_app_inc directly for netns context.
Or may be this will be the part that will remain in the
init_netns handler for FTP... and register_ip_vs_app
will be for ip_vs_ftp_init.

> >- new: global list for registered apps
> >- present: app per netns: to hold incs_list
> >- present: inc (app instance for port) per netns: to hold the
> >instance in the per-netns context of proto

Regards

--
Julian Anastasov <ja@ssi.bg>
