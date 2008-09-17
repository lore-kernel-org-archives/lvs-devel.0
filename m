From: Chris Snook <csnook@redhat.com>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Wed, 17 Sep 2008 14:37:33 -0400
Message-ID: <48D14E6D.4020407@redhat.com>
References: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> Since IPVS now does partial IPv6, should we finally move it from
> "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
> long time ago, but that was before any of the actual v6 features, so
> there was probably no interest.

Whatever the netfilter people want is fine with me.

> Also, the tunables in /proc/sys/net/ipv4/vs/... apply to both v4 and
> v6. Should we just duplicate them into /proc/sys/net/ipv6/vs? Or will
> people be confused that setting a value in one directory changes the
> value in the other and affects both IP versions?

If we do any duplication of sysctl tunables under net.ipv4 into net.ipv6, we 
need to follow the same policy for all of them.  Since the tcp tunables in 
net.ipv4 are among the most documented and used, and have been for a decade, we 
need to be conservative with that.  Having two different writable tunables for 
the same variable is certain to confuse.  Having read-only aliases under 
net.ipv6 wouldn't terrify me, but the last time I went to do tcp tuning, and saw 
that the tunables in net.ipv4 weren't duplicated under net.ipv6, it was obvious 
what was going on at first glance, without needing to do an ls -l to figure out 
what was going on.  People who prefer to use sysctl rather than manually 
tweaking pseudofiles might not notice the permissions right away.  By the 
principle of least confusion, I think omitting them entirely is probably the way 
to go.

-- Chris
