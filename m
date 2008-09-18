From: Simon Horman <horms@verge.net.au>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Thu, 18 Sep 2008 14:24:36 +1000
Message-ID: <20080918042436.GB32516@verge.net.au>
References: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com> <48D14E6D.4020407@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48D14E6D.4020407@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Snook <csnook@redhat.com>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Sep 17, 2008 at 02:37:33PM -0400, Chris Snook wrote:
> Julius Volz wrote:
>> Since IPVS now does partial IPv6, should we finally move it from
>> "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
>> long time ago, but that was before any of the actual v6 features, so
>> there was probably no interest.
>
> Whatever the netfilter people want is fine with me.
>
>> Also, the tunables in /proc/sys/net/ipv4/vs/... apply to both v4 and
>> v6. Should we just duplicate them into /proc/sys/net/ipv6/vs? Or will
>> people be confused that setting a value in one directory changes the
>> value in the other and affects both IP versions?
>
> If we do any duplication of sysctl tunables under net.ipv4 into net.ipv6, 
> we need to follow the same policy for all of them.  Since the tcp 
> tunables in net.ipv4 are among the most documented and used, and have 
> been for a decade, we need to be conservative with that.  Having two 
> different writable tunables for the same variable is certain to confuse.  
> Having read-only aliases under net.ipv6 wouldn't terrify me, but the last 
> time I went to do tcp tuning, and saw that the tunables in net.ipv4 
> weren't duplicated under net.ipv6, it was obvious what was going on at 
> first glance, without needing to do an ls -l to figure out what was going 
> on.  People who prefer to use sysctl rather than manually tweaking 
> pseudofiles might not notice the permissions right away.  By the  
> principle of least confusion, I think omitting them entirely is probably 
> the way to go.

If thats a standard practice, than that sounds reasonable to me.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

