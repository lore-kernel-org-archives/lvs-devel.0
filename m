From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next,v4 00/14] ipvs: Add icmp scheduling
Date: Tue, 1 Sep 2015 10:38:17 +0900
Message-ID: <20150901013817.GC29746@verge.net.au>
References: <1440611272-437619-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440611272-437619-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, alexgartrell@gmail.com, kernel-team@fb.com, Pablo Neira Ayuso <pablo@netfilter.org>

[CC Pablo]

Hi Alex,

On Wed, Aug 26, 2015 at 10:47:52AM -0700, Alex Gartrell wrote:
> The configuration of ipvs at Facebook is relatively straightforward.  All
> ipvs instances bgp advertise a set of VIPs and the network prefers the
> nearest one or uses ECMP in the event of a tie.  For the uninitiated, ECMP
> deterministically and statelessly load balances by hashing the packet
> (usually a 5-tuple of protocol, saddr, daddr, sport, and dport) and using
> that number as an index (basic hash table type logic).
> 
> The problem is that ICMP packets (which contain really important
> information like whether or not an MTU has been exceeded) will get a
> different hash value and may end up at a different ipvs instance.  With no
> information about where to route these packets, they are dropped, creating
> ICMP black holes and breaking Path MTU discovery.  Suddenly, my mom's
> pictures can't load and I'm fielding midday calls that I want nothing to do
> with.
> 
> To address this, this patch set introduces the ability to schedule icmp
> packets which is gated by a sysctl net.ipv4.vs.schedule_icmp.  If set to 0,
> the old behavior is maintained -- otherwise ICMP packets are scheduled.

Nice work.

I have queued these up with Julian's Ack in the ipvs-next tree.

At this stage my plan is to send a pull request to Pablo targeted
at v4.4 after v4.3-rc1 has been released. I will probably rebase ipvs-next
at that time.
