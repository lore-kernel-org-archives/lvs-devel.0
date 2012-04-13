From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: fix app registration in netns
Date: Fri, 13 Apr 2012 16:14:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204131547320.1806@ja.ssi.bg>
References: <1334306642-3765-1-git-send-email-ja@ssi.bg> <1334306642-3765-3-git-send-email-ja@ssi.bg> <201204131147.49259.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201204131147.49259.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>


	Hello,

On Fri, 13 Apr 2012, Hans Schillstrom wrote:

> Hello Julian
> On Friday 13 April 2012 10:44:02 Julian Anastasov wrote:
> > 	Avoid crash when registering applications (ftp) when
> > the IPVS core initialization for netns fails. Do this by
> > checking for present core (net->ipvs) when registering apps.
> > 
> > 	As result this gets rid of the ftp_app pointer and allows
> > applications to be registered without adding fields in the
> > netns_ipvs structure.
> > 
> > 	Also, make sure applications are unregistered from the
> > core automatically, should not be needed in theory.
> > 
> 
> I think we can do this much simpler,
> remove the auto init of ftp (ip_vs_ftp_init and ip_vs_ftp_exit) 
> and let ip_vs_app call __ip_vs_ftp_init() as a we do with the protocols.
> 
> If the init fails before ip_vs_app_net_init() ftp init will not be called
> and if it fails after a proper cleanup will be performed.
> 
> i.e. same design every where.
> 
> ex remove the
>  ip_vs_ftp_init(void)
>  ip_vs_ftp_exit(void)

	OK, go ahead. But also change init_netns for
proto (and now for apps) to return int error. Now
__ip_vs_tcp_init does not return error if the
pd->timeout_table allocation fails. This is fatal.

	May be you can do this change on top of these
two patches because init_netns for ftp should be NULL,
we do not need to allocate anything for netns. Only
&ip_vs_ftp should go in some new global list to be cloned
for every netns as my 2nd patch:

- new: global list for registered apps
- present: app per netns: to hold incs_list
- present: inc (app instance for port) per netns: to hold the
instance in the per-netns context of proto

Regards

--
Julian Anastasov <ja@ssi.bg>
