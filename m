From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs-next] ipvs: Remove rcu_read_unlock();rcu_read_lock();
Date: Thu, 25 Apr 2013 22:36:39 +0900
Message-ID: <20130425133639.GC10898@verge.net.au>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
 <1366880726.2628.177.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366880726.2628.177.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Thu, Apr 25, 2013 at 11:05:26AM +0200, Hans Schillstrom wrote:
> Hello
> On Thu, 2013-04-25 at 11:15 +0300, Julian Anastasov wrote:
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
> > it has limit of 16384 rows. Not sure how fatal is to try 1048576
> > empty rows under RCU lock for such rare operations as
> > connection listing. OTOH, ip_vs_conn_array() needs to
> > seek at some initial position, so it can skip many
> > entries if reading table with many conns, for example,
> > 1048576 rows * 16 conns per row, we will need to
> > touch 16777216 conns under lock. Not sure what is the
> > best practice for such cases.
> 
> My opinion is to keep it, people tends to do such "rare" things.
> It's not unusual with 256k - 1M rows... 

Ok, leaving it seems reasonable.
Pablo, do you have any objections?

