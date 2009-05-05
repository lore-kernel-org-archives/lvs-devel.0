From: Simon Horman <horms@verge.net.au>
Subject: Re: Ldirectord Feature Request
Date: Tue, 5 May 2009 22:45:22 +1000
Message-ID: <20090505124520.GA19402@verge.net.au>
References: <33afbbe70905011318j35d226a6h31e0dfaeb1b77b45@mail.gmail.com> <20090502021644.GA15603@verge.net.au> <Pine.LNX.4.64.0905020531001.18799@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905020531001.18799@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Caleb Anthony <caleb.anthony@gmail.com>, lvs-devel@vger.kernel.org

Hi Joe,

On Sat, May 02, 2009 at 05:33:43AM -0700, Joseph Mack NA3T wrote:
>
> On Sat, 2 May 2009, Simon Horman wrote:
>
>> I'll double check, but I think the weight specifies a proportion
>> of conections rather than an absolute number. Could you let
>> me know which documentation you are looking at?
>
> it's the number of connections
>
> see section 4.10.2 of
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.ipvsadm.html#SH-scheduler

That may have been the case in the past, but examining the code now
I don't see any evidence of weight = number of connections for the purpose
of calculating overload.

As far as I can see a real-server is only regarded as
being overloaded if the IP_VS_DEST_F_OVERLOAD flag is set.
And that flag only seems to be set in ip_vs_bind_dest()
where the criteria is that u-threshhold - as supplied
by ipvsadm - has been exceeded.

Specifically, I am looking at ip_vs_sh_schedule(), ip_vs_sh_get()
and is_overloaded() in net/netfilter/ipvs/ip_vs_sh.c in 2.6.30-rc4.

Caleb, are you observing that weight = number of connections?
If so, which kernel are you running?

> no-one used the -SH scheduler for years because no-one understood how to 
> use it. I expect that weighting by the number of connections was probably 
> the easiest to code up, but it's not particularly useful

I agree with your comments regarding utility.
If it is the case then I think it should be changed.

-- 
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

