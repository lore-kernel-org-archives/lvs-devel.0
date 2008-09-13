From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sat, 13 Sep 2008 11:58:10 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809131157140.25859@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> 
 <Pine.LNX.4.64.0809131100320.20936@wm7d.net> <1221332109.4327.25.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1221332109.4327.25.camel@ernie.internal.graemef.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Graeme Fowler <graeme@graemef.net>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sat, 13 Sep 2008, Graeme Fowler wrote:

> It's simultaneously a problem in that for (say) an HTTP server, all the
> requests will appear to be sourced from the director's internal address.
> For many applications this won't be acceptable, not least in that for
> the webserver case log processing will be an irrelevance!

hmm, hadn't thought about this.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
