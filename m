From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v4 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 16 Nov 2010 08:22:35 +0100
Message-ID: <201011160822.35551.hans.schillstrom@ericsson.com>
References: <201011151931.26789.hans.schillstrom@ericsson.com> <20101116064436.GA19642@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101116064436.GA19642@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

On Tuesday 16 November 2010 07:44:39 Simon Horman wrote:
> On Mon, Nov 15, 2010 at 07:31:26PM +0100, Hans Schillstrom wrote:
> > This patch series adds/(updates) the following functionality
> > in the synchronization between master and backup daemons.
> > 
> >  - IPv6
> >  - Persistence Engine
> >  - Firewall marks transferred
> >  - Time-outs transferred.
> >  - Flag field increased to 32 bits.
> > 
> > Note:
> > It depends on Patch 1-9 in staging branch.
> > "IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon."
> > to ...
> > "IPVS: skb defrag in L7 helpers"
> 
> Hi Hans,
> 
> unfortuantely I am a bit confused about which tree your patches apply to.

I was your staging branch, as you suggested.

> 
> I have sent a pull request to Patrick just now and as part of that
> I have updated the master, for-patrick, and stable branches such
> that they are currently all the same thing. This means stable has
> been purged and then re-added. In the process I dropped the following
> patches:
> 
> * IPVS: ip_vs_pe.c, use strncmp to be safe.
> 
>   Julian didn't seem very happy with this change.
>   He suggested using pe->name_len to be safe.
> 
> * IPVS: Prepare for transferring firewall marks (fwmark) to the backup daemon.
> 
>   I believe you have revised this idea
> 
> * IPVS: Backup, Adding structs for new sync format
> 
>   I believe this one has changed too.
> 
> I notice that Julian made some comments too.  When you are ready could you
> please post a fresh patch series, that includes all required patches and
> applies cleanly on top of the master branch of lvs-next-2.6?

I will send new fresh ones today for all that I need

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
