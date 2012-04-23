From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix crash in ip_vs_control_net_cleanup on unload
Date: Mon, 23 Apr 2012 22:17:16 +0900
Message-ID: <20120423131716.GA13990@verge.net.au>
References: <6dfqp4f.0faa011ca6cbe5c145c1b21e1d17f9ad@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6dfqp4f.0faa011ca6cbe5c145c1b21e1d17f9ad@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Fri, Apr 13, 2012 at 09:51:13PM +0200, Hans Schillstrom wrote:
> Hello Julian
> It looks  OK
> 
> >---- Original Message ----
> >From: Julian Anastasov <ja@ssi.bg>
> >To: "Simon Horman" <horms@verge.net.au>
> >Cc: lvs-devel@vger.kernel.org
> >Sent: Fri, Apr 13, 2012, 5:10 PM
> >Subject: [PATCH] ipvs: fix crash in ip_vs_control_net_cleanup on unload
> >
> >commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
> >("Add __ip_vs_control_{init,cleanup}_sysctl()")
> >introduced regression due to wrong __net_init for
> >__ip_vs_control_cleanup_sysctl. This leads to crash when
> >the ip_vs module is unloaded.
> >
> >	Fix it by changing __net_init to __net_exit for
> >the function that is already renamed to ip_vs_control_net_cleanup_sysctl.
> >
> >Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

Thanks, I have pushed this to ipvs and sent a pull request to
Pablo to consider inclusion in 3.4.
