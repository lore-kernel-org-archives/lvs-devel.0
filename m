From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count = 8
Date: Mon, 18 Apr 2011 08:10:26 +0200
Message-ID: <201104180810.27198.hans@schillstrom.com>
References: <201104150901.47214.hans@schillstrom.com> <alpine.LFD.2.00.1104152229450.1730@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1104152229450.1730@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Friday, April 15, 2011 22:11:32 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 15 Apr 2011, Hans Schillstrom wrote:
> 
> > Hello Julian
> > 
> > I'm trying to fix the cleanup process when a namespace get "killed",
> > which is a new feature for ipvs. However an old problem appears again
> > 
> > When there has been traffic trough ipvs where the destination is unreachable
> > the usage count on loopback dev increases one for every packet....
> 
> 	What is the kernel version?

net-next-2.6  i.e. 2.6.39-rc2

> 
> > I guess thats because of this rule :
> > 
> > # ip route list table all
> > ...
> > unreachable default dev lo  table 0  proto kernel  metric 4294967295  error -101 hoplimit 25
> > ...
> > 
> > I made a test just forwarding packets through the same container (ipvs loaded)
> > to an unreachable destination and that test had a balanced count i.e. it was possible to reboot the container.
> 
> 	Can you explain, what do you mean with unreachable
> destination? Are you adding some rejecting route?

This comment from Eric, do explain what happens:

"Hans.  
I do know that most outstanding references when you clean up a
container get moved to the loopback device.  So it may not originally
be the loopback device itself where the reference counting is wrong.

Eric"

> 
> > Do you have an idea why  this happens in the ipvs case ?
> 
> 	Do you see with debug level 3 the "Removing destination"
> messages. Only real servers can hold dest->dst_cache reference
> for dev which can be a problem because the real servers are not
> deleted immediately - on traffic they are moved to trash
> list. But ip_vs_trash_cleanup() should remove any left
> structures. You should check in debug that all servers are
> deleted. If all real server structures are freed but
> problem remains we should look more deeply in the
> dest->dst_cache usage. DR or NAT is used?

I have got some wise words from Eric, 
i.e. moved all ipvs register/unregister from subsys to device 
that solved plenty of my issues
(Thanks Eric)

I'll will post a Patch later on regarding this.

> 
> 	I assume cleanup really happens in this order:
> 
> ip_vs_cleanup():
> 	nf_unregister_hooks()

This will not happens in a namespace since nf_unregister_hooks() is not per netns.
We might need a flag but I don't think so, further test will show....

> 	...
> 	ip_vs_conn_cleanup()
> 	...
> 	ip_vs_control_cleanup()
> 

Regards
Hans
