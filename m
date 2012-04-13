From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/2] ipvs: fix app registration in netns
Date: Fri, 13 Apr 2012 11:47:48 +0200
Message-ID: <201204131147.49259.hans.schillstrom@ericsson.com>
References: <1334306642-3765-1-git-send-email-ja@ssi.bg> <1334306642-3765-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1334306642-3765-3-git-send-email-ja@ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hello Julian
On Friday 13 April 2012 10:44:02 Julian Anastasov wrote:
> 	Avoid crash when registering applications (ftp) when
> the IPVS core initialization for netns fails. Do this by
> checking for present core (net->ipvs) when registering apps.
> 
> 	As result this gets rid of the ftp_app pointer and allows
> applications to be registered without adding fields in the
> netns_ipvs structure.
> 
> 	Also, make sure applications are unregistered from the
> core automatically, should not be needed in theory.
> 

I think we can do this much simpler,
remove the auto init of ftp (ip_vs_ftp_init and ip_vs_ftp_exit) 
and let ip_vs_app call __ip_vs_ftp_init() as a we do with the protocols.

If the init fails before ip_vs_app_net_init() ftp init will not be called
and if it fails after a proper cleanup will be performed.

i.e. same design every where.

ex remove the
 ip_vs_ftp_init(void)
 ip_vs_ftp_exit(void)

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
