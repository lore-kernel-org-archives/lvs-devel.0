From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs-next] ipvs: Remove
 rcu_read_unlock();rcu_read_lock();
Date: Fri, 26 Apr 2013 09:02:56 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304260900080.1758@ja.ssi.bg>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg> <20130426005900.GA4303@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130426005900.GA4303@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Fri, 26 Apr 2013, Pablo Neira Ayuso wrote:

> Hi Julian,
> 
> On Thu, Apr 25, 2013 at 11:15:25AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Thu, 25 Apr 2013, Simon Horman wrote:
> > 
> > > It is unclear to me that there is any utility in the following:
> > > 
> > > 	 rcu_read_unlock();
> > > 	 rcu_read_lock();
> > 
> > 	I thought it is a good idea for fixed hash table
> > of IP_VS_TAB_BITS=20. May be if guarded by
> > 
> > 	if (!((++idx) & 4095))
> > 
> > to reduce its rate to 256 (with idx++ removed from the for loop) ?
> > 
> > 	Netfilter has no such logic for nf_conntrack because
> > it has limit of 16384 rows.
> 
> We seem to be supporting over that limit via module_param and sysfs:
> 
> /sys/module/nf_conntrack/parameters/hashsize

	Thanks for the note, I overlooked this parameter.

Regards

--
Julian Anastasov <ja@ssi.bg>
