From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: avoid netns exit crash on
 ip_vs_conn_drop_conntrack
Date: Wed, 16 Jul 2014 09:39:46 +0900
Message-ID: <20140716003946.GE25244@verge.net.au>
References: <1404973441-8989-1-git-send-email-ja@ssi.bg>
 <1404979400.16647.34.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404979400.16647.34.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Thu, Jul 10, 2014 at 10:03:20AM +0200, Hans Schillstrom wrote:
> Hi Julian
> 
> 
> On Thu, 2014-07-10 at 09:24 +0300, Julian Anastasov wrote: 
> > commit 8f4e0a18682d91 ("IPVS netns exit causes crash in conntrack")
> > added second ip_vs_conn_drop_conntrack call instead of just adding
> > the needed check. As result, the first call still can cause
> > crash on netns exit. Remove it.
> > 
> 
> Oops must have forgot to take that row away
> 
> 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

Thanks, applied.


