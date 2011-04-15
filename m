From: Hans Schillstrom <hans@schillstrom.com>
Subject: unregister_netdevice: waiting for lo to become free. Usage count = 8
Date: Fri, 15 Apr 2011 09:01:46 +0200
Message-ID: <201104150901.47214.hans@schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

Hello Julian

I'm trying to fix the cleanup process when a namespace get "killed",
which is a new feature for ipvs. However an old problem appears again

When there has been traffic trough ipvs where the destination is unreachable
the usage count on loopback dev increases one for every packet....
I guess thats because of this rule :

# ip route list table all
...
unreachable default dev lo  table 0  proto kernel  metric 4294967295  error -101 hoplimit 25
...

I made a test just forwarding packets through the same container (ipvs loaded)
to an unreachable destination and that test had a balanced count i.e. it was possible to reboot the container.

Do you have an idea why  this happens in the ipvs case ?

Regards
Hans Schillstrom <hans@schillstrom.com>
