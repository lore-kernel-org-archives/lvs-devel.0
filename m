From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Mon, 15 Sep 2008 18:54:04 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809151852060.9622@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
 <20080915014337.GA10026@verge.net.au> <Pine.LNX.4.64.0809150815580.32594@wm7d.net>
 <200809161031.58743.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200809161031.58743.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: Simon Horman <horms@verge.net.au>, Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Siim =?utf-8?q?P=C3=B5der?= <siim@p6drad-teel.net>

On Tue, 16 Sep 2008, Jason Stubbs wrote:

> For what it's worth, I'm currently using DNAT alongside LVS-NAT
> for certain connections. It only serves a secondary purpose and
> there are other ways (although not as simple) to achieve the
> purpose, but it has proven useful.

I'm having a bit of trouble fitting DNAT into the OUTPUT of 
a director (at least on the OUTPUT of the inside nic). What 
are you doing this for?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
