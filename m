From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH ipvs-next] ipvs: Remove rcu_read_unlock();rcu_read_lock();
Date: Fri, 26 Apr 2013 02:59:26 +0200
Message-ID: <20130426005900.GA4303@localhost>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

Hi Julian,

On Thu, Apr 25, 2013 at 11:15:25AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 25 Apr 2013, Simon Horman wrote:
> 
> > It is unclear to me that there is any utility in the following:
> > 
> > 	 rcu_read_unlock();
> > 	 rcu_read_lock();
> 
> 	I thought it is a good idea for fixed hash table
> of IP_VS_TAB_BITS=20. May be if guarded by
> 
> 	if (!((++idx) & 4095))
> 
> to reduce its rate to 256 (with idx++ removed from the for loop) ?
> 
> 	Netfilter has no such logic for nf_conntrack because
> it has limit of 16384 rows.

We seem to be supporting over that limit via module_param and sysfs:

/sys/module/nf_conntrack/parameters/hashsize

Regards.
