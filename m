From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: SNAT packet replies only for NATed connections
Date: Mon, 1 May 2017 11:48:46 +0200
Message-ID: <20170501094844.GJ18349@verge.net.au>
References: <20170429173309.16305-1-ja@ssi.bg>
 <20170501075542.GD18349@verge.net.au>
 <alpine.LFD.2.20.1705011125350.2663@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493632130; bh=n335s/kJrINz9gnpbJmhKuKEqPuHxaYhBK2CjBV1KPM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=HKKy+YEdsIA1zwlBwVZBpeHW5ie7rTYuRY7pRJh2MLmu7JdfdpiDpGgYjyJWIPuRg
         XhTC/lidRnDLECQnaVUA6/iDSEn/Ssb/2NGHcMaKkQBb5M7Ew1QO4xHOVzjYggRwEP
         +/FlwiO7BgHcPskxHKVVwYlIywYkE3fNtvBhTU5k=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1705011125350.2663@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Nick Moriarty <nick.moriarty@york.ac.uk>

On Mon, May 01, 2017 at 11:28:59AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 1 May 2017, Simon Horman wrote:
> 
> > On Sat, Apr 29, 2017 at 08:33:09PM +0300, Julian Anastasov wrote:
> > > We do not check if packet from real server is for NAT
> > > connection before performing SNAT. This causes problems
> > > for setups that use DR/TUN and allow local clients to
> > > access the real server directly, for example:
> > > 
> > > - local client in director creates IPVS-DR/TUN connection
> > > CIP->VIP and the request packets are routed to RIP.
> > > Talks are finished but IPVS connection is not expired yet.
> > > 
> > > - second local client creates non-IPVS connection CIP->RIP
> > > with same reply tuple RIP->CIP and when replies are received
> > > on LOCAL_IN we wrongly assign them for the first client
> > > connection because RIP->CIP matches the reply direction.
> > > As result, IPVS SNATs replies for non-IPVS connections.
> > > 
> > > The problem is more visible to local UDP clients but in rare
> > > cases it can happen also for TCP or remote clients when the
> > > real server sends the reply traffic via the director.
> > > 
> > > So, better to be more precise for the reply traffic.
> > > As replies are not expected for DR/TUN connections, better
> > > to not touch them.
> > > 
> > > Reported-by: Nick Moriarty <nick.moriarty@york.ac.uk>
> > > Tested-by: Nick Moriarty <nick.moriarty@york.ac.uk>
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > ---
> > > 
> > > I know that 4.11 is to be released soon, I prefer this patch
> > > to linger in the net tree during the 4.12-rc cycle.
> > 
> > I have no problem with queueing this up as a fix for v4.12 as you describe
> > but do you also want it to be considered for -stable?
> 
> 	Yes, I'll post patches for stable kernels later today.

Thanks, I have pushed this patch to the ipvs tree.
