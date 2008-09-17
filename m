From: David Miller <davem@davemloft.net>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Wed, 17 Sep 2008 13:14:45 -0700 (PDT)
Message-ID: <20080917.131445.19943427.davem@davemloft.net>
References: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
	<48D14E6D.4020407@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <48D14E6D.4020407@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: csnook@redhat.com
Cc: juliusv@google.com, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Chris Snook <csnook@redhat.com>
Date: Wed, 17 Sep 2008 14:37:33 -0400

> Julius Volz wrote:
> > Since IPVS now does partial IPv6, should we finally move it from
> > "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
> > long time ago, but that was before any of the actual v6 features, so
> > there was probably no interest.
> 
> Whatever the netfilter people want is fine with me.

I think, especially in the long term, putting IPVS under net/netfilter/
is the right thing to do.
