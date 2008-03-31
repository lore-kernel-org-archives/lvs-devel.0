From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 04:41:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0803310435160.9996@wm7d.net>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com> 
 <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
 <f4845fc0803310348u37b128e4paa5260d243489352@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0803310348u37b128e4paa5260d243489352@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org

On Mon, 31 Mar 2008, Julius Volz wrote:

> Thanks for the warning, I guess you are talking about this (and the
> following points):
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-Tun.html#MTU
>
> Does this have any special implications in the IPv6 case?

possibly, possibly not. I was just warning you so that if 
you came across it, you would recognize it.

> The problem looks pretty complicated and no one seems to 
> completely understand it ;) I will keep it in mind for 
> later though.

>>  We don't have enough people using UDP to know how LVS should
>>  handle UDP.

> Again, interesting info. Is there a specific relation to 
> IPv6 though?

I assume you'll be testing UDP, and if it behaves strangely, 
you'll want to know which parts to blame us for :-)

> Aha, interesting. Could you explain a bit more for a 
> newbie in what ways IPVS "bypasses" netfilter?

LVS controlled packets don't always follow the netfilter 
path. They appear in the output without going through the 
middle. So iptables rules don't always work.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
