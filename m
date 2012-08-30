From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Multiple load balancers problem
Date: Thu, 30 Aug 2012 23:00:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208302249490.1629@ja.ssi.bg>
References: <thl3856.36e267c5beb1d7b35e7e87b807e0b5f4@obelix.schillstrom.com> <503FA1B4.6090600@stalker.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <503FA1B4.6090600@stalker.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Akindinov <dimak@stalker.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org


	Hello,

On Thu, 30 Aug 2012, Dmitry Akindinov wrote:

> Installed CentOS 6.3 and the kernel 3.5.3 from elrepo.org
> 
> [root@fe3 ~]# uname -a
> Linux fe3.msk 3.5.3-1.el6.elrepo.x86_64 #1 SMP Sun Aug 26 14:05:15 EDT 2012
> x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> But we still see the same problem: connections to the old balancer are RSET'ed
> when the new balancer takes over. Any idea which particular kernel we need to
> use? Or, do we need to apply some specific patches and build our own kernel?

	This kernel has everything you need. Is it installed
on both machines? Do you see that new balancer forwards
traffic to old balancer, i.e. who exactly sends the resets?
Old or new balancer?

> Thank you for all your help so far!
> 
> > BR
> > Hans
> > 
> 
> -- 
> Best regards,
> Dmitry Akindinov

Regards

--
Julian Anastasov <ja@ssi.bg>
