From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 04:43:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0803310441440.9996@wm7d.net>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
 <Pine.LNX.4.64.0803280853110.28825@wm7d.net> <20080331030715.GH31306@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080331030715.GH31306@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org

On Mon, 31 Mar 2008, Simon Horman wrote:

> [ Joe, I'm not sure that the LOCAL_IN stuff is really related
>  specifically to IPv6. But you do remind me that those patches
>  need to be revisited. ]

Agree, but we don't want Julius writing code for LOCAL_IN at 
the same time we're moving the hook elsewhere.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
