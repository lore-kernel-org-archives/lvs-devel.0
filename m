From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next] ipvs: use 64-bit rates in stats
Date: Fri, 30 Jan 2015 10:33:26 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501301019410.4504@ja.home.ssi.bg>
References: <1422348415-29484-1-git-send-email-ja@ssi.bg> <20150130010011.GC11897@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150130010011.GC11897@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Chris Caputo <ccaputo@alt.net>


	Hello,

On Fri, 30 Jan 2015, Simon Horman wrote:

> On Tue, Jan 27, 2015 at 10:46:55AM +0200, Julian Anastasov wrote:
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
> 
> This seems reasonable to me, let me know if you would like me to queue it up.
> 
> The ipvsadm patch also seems fine to me.

	I didn't accumulated other changes to these patches,
so they can be applied as is. If needed, I can submit the
ipvsadm patch again because I didn't sent a copy to Jesper.
In fact, we do not need to hurry with these patches, no problem
if we apply them after the next merge window. Lets give
some time, in case someone has idea for new attribute or
other changes for stats.

Regards

--
Julian Anastasov <ja@ssi.bg>
