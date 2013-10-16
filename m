From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] ipvs: avoid rcu_barrier during netns cleanup
Date: Wed, 16 Oct 2013 22:52:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310162231380.1917@ssi.bg>
References: <1381802507-7934-1-git-send-email-horms@verge.net.au> <1381802507-7934-3-git-send-email-horms@verge.net.au> <20131016104306.GA10288@localhost>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131016104306.GA10288@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Wed, 16 Oct 2013, Pablo Neira Ayuso wrote:

> I can enqueue this fix to nf if you like. No need to resend, I can
> manually apply.
> 
> Let me know.

	It is not critical. I waited weeks the net tree to be
copied into net-next because it collides with the recent
"ipvs: make the service replacement more robust" change in
net tree :) But if a rcu_barrier in the netns cleanup looks
scary enough you can push it to nf. IMHO, it just adds
unneeded delay there.

Regards

--
Julian Anastasov <ja@ssi.bg>
