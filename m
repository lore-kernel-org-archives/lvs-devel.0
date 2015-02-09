From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: use 64-bit rates in stats
Date: Mon, 9 Feb 2015 08:41:32 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502090837580.7931@ja.home.ssi.bg>
References: <1423208684-11847-1-git-send-email-ja@ssi.bg> <20150209052602.GB9021@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150209052602.GB9021@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Chris Caputo <ccaputo@alt.net>


	Hello,

On Mon, 9 Feb 2015, Simon Horman wrote:

> On Fri, Feb 06, 2015 at 09:44:44AM +0200, Julian Anastasov wrote:
> > IPVS stats are limited to 2^(32-10) conns/s and packets/s,
> > 2^(32-5) bytes/s. It is time to use 64 bits:
> > 
> > * Change all conn/packet kernel counters to 64-bit and update
> > them in u64_stats_update_{begin,end} section
> > 
> > * In kernel use struct ip_vs_kstats instead of the user-space
> > struct ip_vs_stats_user and use new func ip_vs_export_stats_user
> > to export it to sockopt users to preserve compatibility with
> > 32-bit values
> > 
> > * Rename cpu counters "ustats" to "cnt"
> > 
> > * To netlink users provide additionally 64-bit stats:
> > IPVS_SVC_ATTR_STATS64 and IPVS_DEST_ATTR_STATS64. Old stats
> > remain for old binaries.
> > 
> > * We can use ip_vs_copy_stats in ip_vs_stats_percpu_show
> > 
> > Thanks to Chris Caputo for providing initial patch for ip_vs_est.c
> > 
> > Signed-off-by: Chris Caputo <ccaputo@alt.net>
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> > 
> > Nothing is changed from previous RFC version.
> 
> Hi Julian,
> 
> I'm happy to take this. Can you confirm that you are ready for me to do so?

	Yep, please apply.

Regards

--
Julian Anastasov <ja@ssi.bg>
