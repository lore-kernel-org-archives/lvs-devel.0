From: Jason Stubbs <jasonbstubbs@gmail.com>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Sat, 12 Apr 2008 00:15:41 +0900
Message-ID: <200804120015.41545.jasonbstubbs@gmail.com>
References: <200804111400.12331.j.stubbs@linkthink.co.jp> <200804112213.32476.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0804110729030.3476@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804110729030.3476@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Friday 11 April 2008 23:38:30 JST, Joseph Mack NA3T wrote:
> On Fri, 11 Apr 2008, Jason Stubbs wrote:
> >>> Is there any problem with essentially hiding the real
> >>> servers from netfilter?
> >>
> >> I don't know what this means (I didn't know that netfilter
> >> knew about the realservers).
> >
> > I mean that it'd be nice for rules to go something like:
> > * Allow from external to VIP
> > * Allow anything established
> > * Drop everything else
> >
> > Depending on where LVS translations are placed in the netfilter path,
> > rules allowing traffic from external to RIPs may also be needed.
>
> I would hope people don't do this. RIPs should be private,
> for security reasons and to preserve the fiction that the
> LVS setup is one machine.

This is precisely why I chose the hooks that I did. My intention was for the 
netfilter chains to only ever see the VIP, but packets with the RIP are going 
through too after IP_VS_XMIT is called.

> The LVS'ed application running on the realserver might start a client 
> process that needs to contact 0/0, but that can be nat'ed out, possibly 
> through the VIP on the director, or maybe some other public IP available to 
> the realserver. Is this what you want to do?   
>
> see
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-DR.html#Pearthree

I didn't quite follow this. Are you referring to services such as FTP? Nothing 
should have changed in this regard with my patch. The link did remind me that 
I need to test the sync daemon with my patch though. :)

> I take it that you're working late at night on this :-)

Nope, I'm not that crazy. Just reading and responding to work emails from home 
as per usual. ;)

-- 
Jason Stubbs
