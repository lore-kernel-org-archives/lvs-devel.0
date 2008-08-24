From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Sat, 23 Aug 2008 19:13:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808231840530.23506@wm7d.net>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> 
 <20080821011715.GG19235@verge.net.au>  <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
  <20080821212948.GB4407@verge.net.au> <20080821220444.GA2758@verge.net.au>
  <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com> 
 <1219399551.4246.10.camel@ernie.internal.graemef.net> 
 <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com> 
 <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net> 
 <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com> 
 <1219483206.10379.5.camel@ernie.internal.graemef.net> 
 <Pine.LNX.4.64.0808230818480.21220@wm7d.net> <1219509119.10379.8.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1219509119.10379.8.camel@ernie.internal.graemef.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Graeme Fowler <graeme@graemef.net>
Cc: Julius Volz <juliusv@google.com>, Sven Wegener <sven.wegener@stealer.net>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Sat, 23 Aug 2008, Graeme Fowler wrote:

>> I don't think we should promise anything.
>
> Well, it was just a suggestion. It'd be nice, I reckon, to 
> be able to say to people on lvs-users who ask us that 
> "yes, this is currently being worked on" at the very 
> least.

If you say that then people will expect that it will 
eventually be released and will work, and be documented and 
we'll be able to help people get it working when it arrives.

A lot of stuff has been "worked on", but not tested or 
released. Horms has piles of stuff. Jason Stubbs has working 
code for lvs hooked into PREROUTING, a great step forward in 
my estimate, but has disappeared off the mailing list. If 
you tell people all this code is out there somewhere, being 
worked on, are you then prepared to tell them that you don't 
have the code, or that no-one's tested it, and there's no 
documentation and you haven't a clue how to set it up, and 
then try to help them install it and get it going? I'm quite 
prepared to believe that you can get Horms version of lvs 
hooked into FORWARD working and help people with it, but I 
can't. There's been more code written for LVS that's never 
seen the light of day, than has ever been released. I 
wouldn't want the LVS mailing list to become famous as a 
list of promises that are not kept.

Even code that's been tested by the author and released 
doesn't get used. The -SH scheduler sat untouched for years, 
because no-one knew how to use it. Someone spelunking the 
code, figured out how to configure it.

I still have no clue what LBLC does and it's been out for 
years.

> It might stop people bleating, as they currently do 
> (albeit rarely).

No-one, who is running LVS as part of his business, and who 
monitors the mailing list daily for at least a year, never 
helping anyone, waiting for a mention of the -SH scheduler, 
so that he remind everyone that the clueless LVS developers 
have not fixed his -SH problem (and that he has no intention 
of fixing it himself, or getting anyone under his command to 
fix it either) and if we don't do something pronto, he'll go 
to a commercial loadbalancer, is entitled to bleat.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
