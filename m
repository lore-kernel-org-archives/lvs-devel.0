From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs:Fix locking requirements in the function
 ip_vs_unlink_service
Date: Sat, 12 Sep 2015 09:20:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509120910090.1626@ja.home.ssi.bg>
References: <1442032025-18642-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1442032025-18642-1-git-send-email-xerofoify@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Krause <xerofoify@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org


	Hello,

On Sat, 12 Sep 2015, Nicholas Krause wrote:

> This fixes locking requirements in the function ip_vs_unlink_service
> to properly use bottom half spinlocking around the call to the function
> __ip_vs_del_service  in order to meet the locking that this paricular
> function requires as stated in it's comments related to locking.

> +	spin_lock_bh(&svc->sched_lock);
>  	__ip_vs_del_service(svc, cleanup);
> +	spin_unlock_bh(&svc->sched_lock);

	BH locking is not needed anymore. Also, sched_lock is
used by schedulers to protect only access to svc->sched_data
fields.

	It seems the comment is outdated after
commit ceec4c381681 ("ipvs: convert services to rcu").

Regards

--
Julian Anastasov <ja@ssi.bg>
