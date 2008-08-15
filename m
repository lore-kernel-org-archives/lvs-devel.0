From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Thu, 14 Aug 2008 17:25:08 -0700 (PDT)
Message-ID: <20080814.172508.15803616.davem@davemloft.net>
References: <20080815001250.GC15825@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080815001250.GC15825@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, sven.wegener@stealer.net, juliusv@google.com, wensong@linux-vs.org, ja@ssi.bg

From: Simon Horman <horms@verge.net.au>
Date: Fri, 15 Aug 2008 10:12:52 +1000

> Julius, Sven and I would particularly like Julius' two changes to go
> in. They add a new interface which is currently unused and thus the
> likelihood of breakage seems low.

Actually these are the two changes that should not go in at this
time.  This netlink stuff is a new feature, therefore not appropriate
to merge outside of the merge window.

Bug fixes only now, please.

Thanks.
