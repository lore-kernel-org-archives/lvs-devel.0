From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 net-next 00/15] IPVS optimizations
Date: Thu, 28 Mar 2013 14:17:56 +0900
Message-ID: <20130328051756.GA10171@verge.net.au>
References: <1363859892-9058-1-git-send-email-ja@ssi.bg>
 <1363946063.14162.20.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363946063.14162.20.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Fri, Mar 22, 2013 at 10:54:23AM +0100, Hans Schillstrom wrote:
> Hello Julian
> Great work!
> 
> On Thu, 2013-03-21 at 11:57 +0200, Julian Anastasov wrote:
> > 	This is a first patchset for IPVS optimizations.
> > Another patchset will address the locking in schedulers
> > and moving the global _bh disabling from LOCAL_OUT to all
> > locks.
> > 
> > 	All patches are for net-next and Simon can
> > take them for ipvs-next.
> > 
> > 	The changes in this patchset eliminate locks
> > and dst refcnt operations from packet processing by
> > using RCU. There are more details in the patches.
> 
> I've gone through all patches and tested them now
> it looks very promising, all my tests have passed.
> 
> Signed-off by: Hans Schillstrom <hans@schillstrom.com>

Thanks, and sorry to be a bit slow.

I will push these to the ipvs-next tree.
I will then post them to netdev and David Miller for
review as I think the first patch falls into that realm.


