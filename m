From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 00/12] IPVS optimizations
Date: Fri, 8 Mar 2013 01:46:58 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303080124340.3035@ja.ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg> <1362650966.18590.127.camel@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362650966.18590.127.camel@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Thu, 7 Mar 2013, Jesper Dangaard Brouer wrote:

> On Wed, 2013-03-06 at 10:42 +0200, Julian Anastasov wrote:
> > 	This is a first patchset for IPVS optimizations.
> > Another patchset will address the locking in schedulers
> > and moving the global _bh disabling from LOCAL_OUT to all
> > locks. It is in TODO list.
> 
> Do you have any performance measurements?

	Unfortunately, I don't have suitable
hardware to do real tests, only virtual setup.

> Or is this code primarily cleanup optimizations, and the next patchset
> will address the performance part?

	This patchset converts all global locks to RCU,
except the __ip_vs_svc_lock usage. The states in
some schedulers probably will need some protection
with lock as before now, others like WLC and LC will
run (after patchset2) just under RCU lock for the 
svc->destinations list. But I'll need some time to
finalize this 2nd patchset because there are other
patches in the queue...

	So, the answer is that packets that create
connections (via schedulers) hit this __ip_vs_svc_lock
with read_lock and some write lock in scheduler.
This happens only when connection is created. Next packets
should not reach any global locks in IPVS. The cached
dst->refcnt is not changed anymore for traffic to
real server.

Regards

--
Julian Anastasov <ja@ssi.bg>
