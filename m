From: Julian Anastasov <ja@ssi.bg>
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count
 = 8
Date: Fri, 15 Apr 2011 23:11:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104152229450.1730@ja.ssi.bg>
References: <201104150901.47214.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201104150901.47214.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>


	Hello,

On Fri, 15 Apr 2011, Hans Schillstrom wrote:

> Hello Julian
> 
> I'm trying to fix the cleanup process when a namespace get "killed",
> which is a new feature for ipvs. However an old problem appears again
> 
> When there has been traffic trough ipvs where the destination is unreachable
> the usage count on loopback dev increases one for every packet....

	What is the kernel version?

> I guess thats because of this rule :
> 
> # ip route list table all
> ...
> unreachable default dev lo  table 0  proto kernel  metric 4294967295  error -101 hoplimit 25
> ...
> 
> I made a test just forwarding packets through the same container (ipvs loaded)
> to an unreachable destination and that test had a balanced count i.e. it was possible to reboot the container.

	Can you explain, what do you mean with unreachable
destination? Are you adding some rejecting route?

> Do you have an idea why  this happens in the ipvs case ?

	Do you see with debug level 3 the "Removing destination"
messages. Only real servers can hold dest->dst_cache reference
for dev which can be a problem because the real servers are not
deleted immediately - on traffic they are moved to trash
list. But ip_vs_trash_cleanup() should remove any left
structures. You should check in debug that all servers are
deleted. If all real server structures are freed but
problem remains we should look more deeply in the
dest->dst_cache usage. DR or NAT is used?

	I assume cleanup really happens in this order:

ip_vs_cleanup():
	nf_unregister_hooks()
	...
	ip_vs_conn_cleanup()
	...
	ip_vs_control_cleanup()

Regards

--
Julian Anastasov <ja@ssi.bg>
