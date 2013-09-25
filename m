From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] ipvs: improved SH fallback strategy
Date: Wed, 25 Sep 2013 10:01:50 +0100
Message-ID: <20130925090150.GC19768@eldamar.org.uk>
References: <20130923115139.GA15034@eldamar.org.uk>
 <524099BA.5020303@cogentembedded.com>
 <20130924093238.GD18494@eldamar.org.uk>
 <20130925003033.GG26081@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130925003033.GG26081@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

> could you add some comments to the code or at least a description of the
> algorithm to the above the function.  The intent of original code may not
> have been obvious to the eye but this version certainly isn't obvious to
> mine.

Sure.  I have a bad habit of assuming that if I understand something,
then others automatically do too. :-)

The original code went through the table, starting at the same place as
the code without fallback and if that returned an unavailable
realserver, it offset the hash by one and repeated the lookup, then added
two, etc., up to IP_VS_SH_TAB_SIZE-1.  So the hash offset was 0,
1, ..., IP_VS_SH_TAB_SIZE-1.

The result is that if a server is down, all traffic destined for it
would fall back onto the next server in the list.

The new code also starts at the same place as the old code (offset 0),
but if that fails, it uses the same fallback strategy as the old code,
but the hash offset is now ihash, ihash + 1, ..., IP_VS_SH_TAB_SIZE-1,
0, 1, ..., ihash - 1, i.e., it starts at ihash instead of 0 and loops
around the table.  ihash could have been a random number, but choosing
it to be something based on the source IP and port (in which case it may
as well be the same hash [offset 0]) means that the behaviour will be
the same on different directors. 

This spreads the load of an unavailable server across the remaining
servers instead of just moving it to the next one in the list.

Hope that makes sense...

I'll submit a patch with a comment shortly.


Alex
