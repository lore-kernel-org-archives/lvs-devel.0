From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH] ipvs: A couple of fixes and cleanups
Date: Sun, 10 Aug 2008 20:35:48 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, 10 Aug 2008, sven.wegener@stealer.net wrote:

> Hi guys,
> 
> here come a couple of fixes and cleanups for IPVS. Worth mentioning are the two
> possible deadlock fixes. One introduced by my last sync daemon work, which
> hasn't hit any stable kernel yet. The other one is in the estimator code and
> goes back to at leat since we started working with git for the kernel. The
> latter I think qualifies for -stable.
> 
> I've pushed the changes (8123b42..2e45552) based on davem's net tree here
> 
> 	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem

I've included the register_ip_vs_protocol() annotation. Changes are now 
8123b42..7ead17b. Diffstat has changed slightly, but is probably not worth 
posting again.

Sven
