From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv3 net-next 00/15] IPVS optimizations
Date: Thu, 28 Mar 2013 10:50:29 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303281047100.2010@ja.ssi.bg>
References: <1363859892-9058-1-git-send-email-ja@ssi.bg> <1363946063.14162.20.camel@hawk.mlab.se> <20130328051756.GA10171@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130328051756.GA10171@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org


	Hello,

On Thu, 28 Mar 2013, Simon Horman wrote:

> On Fri, Mar 22, 2013 at 10:54:23AM +0100, Hans Schillstrom wrote:
> > Hello Julian
> > Great work!
> > 
> > On Thu, 2013-03-21 at 11:57 +0200, Julian Anastasov wrote:
> > > 	This is a first patchset for IPVS optimizations.
> > > Another patchset will address the locking in schedulers
> > > and moving the global _bh disabling from LOCAL_OUT to all
> > > locks.
> > > 
> > > 	All patches are for net-next and Simon can
> > > take them for ipvs-next.
> > > 
> > > 	The changes in this patchset eliminate locks
> > > and dst refcnt operations from packet processing by
> > > using RCU. There are more details in the patches.
> > 
> > I've gone through all patches and tested them now
> > it looks very promising, all my tests have passed.
> > 
> > Signed-off by: Hans Schillstrom <hans@schillstrom.com>
> 
> Thanks, and sorry to be a bit slow.
> 
> I will push these to the ipvs-next tree.
> I will then post them to netdev and David Miller for
> review as I think the first patch falls into that realm.

	He already acked v2 of this patch and I added his
last comment in v3:

http://marc.info/?l=linux-netdev&m=136294921002680&w=2

	I preferred not to disturb netdev with v3, it
has small changes after v2.

Regards

--
Julian Anastasov <ja@ssi.bg>
