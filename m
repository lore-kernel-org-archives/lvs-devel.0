From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Fri, 11 Apr 2008 22:13:32 +0900
Message-ID: <200804112213.32476.j.stubbs@linkthink.co.jp>
References: <200804111400.12331.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0804110530590.22135@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804110530590.22135@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Friday 11 April 2008 21:37:03 JST, Joseph Mack NA3T wrote:
> On Fri, 11 Apr 2008, Jason Stubbs wrote:
> > With local node, 127.0.0.1 doesn't work but an IP address on a local
> > interface does.
>
> that will do.
>
> Local node isn't real important. It was there because it
> could be done, rather than because it was needed. If you can
> do it, we'll take it, but otherwise don't worry a whole lot
> about it.

I did look a little bit further into it. The iptables REDIRECT module maps to 
127.0.0.1 for locally generated traffic and the first IP on the first 
interface otherwise. I haven't tried yet, but the same thing could probably 
done here.

> > LVS-TUN should work as LVS-DR didn't require any direct
> > modification, but it's a little bit of a pain to set up
> > for testing at this stage.
>
> have the same physical setup as LVS-DR and just change the
> if on the realservers to tunl0 and change the
> appropriated ipvsadm lines.

Hmm.. Well seeing I'm trying getting my hands dirty every else, I may as well 
do so here too. Will give it a try on Monday.

> > Is there any problem with essentially hiding the real
> > servers from netfilter?
>
> I don't know what this means (I didn't know that netfilter
> knew about the realservers).

I mean that it'd be nice for rules to go something like:
* Allow from external to VIP
* Allow anything established
* Drop everything else

Depending on where LVS translations are placed in the netfilter path, rules 
allowing traffic from external to RIPs may also be needed. That can get 
pretty complicated, but there might be some need for it that I can't see...

> Will your setup handle the F5-SNAT situation?
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realser
>vers.html#F5_snat

Yep, this is just SNAT as far as I can tell. I tested SNAT on both sides of 
the director and there weren't any problems.

--
Jason Stubbs
