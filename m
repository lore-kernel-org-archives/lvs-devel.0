From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count = 8
Date: Fri, 15 Apr 2011 00:27:20 -0700
Message-ID: <m1d3ko9dpj.fsf@fess.ebiederm.org>
References: <201104150901.47214.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201104150901.47214.hans@schillstrom.com> (Hans Schillstrom's
	message of "Fri, 15 Apr 2011 09:01:46 +0200")
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hans Schillstrom <hans@schillstrom.com> writes:

> Hello Julian
>
> I'm trying to fix the cleanup process when a namespace get "killed",
> which is a new feature for ipvs. However an old problem appears again
>
> When there has been traffic trough ipvs where the destination is unreachable
> the usage count on loopback dev increases one for every packet....
> I guess thats because of this rule :
>
> # ip route list table all
> ...
> unreachable default dev lo  table 0  proto kernel  metric 4294967295  error -101 hoplimit 25
> ...
>
> I made a test just forwarding packets through the same container (ipvs loaded)
> to an unreachable destination and that test had a balanced count i.e. it was possible to reboot the container.
>
> Do you have an idea why  this happens in the ipvs case ?

Hans.  I do know that most outstanding references when you clean up a
container get moved to the loopback device.  So it may not originally
be the loopback device itself where the reference counting is wrong.

Eric
