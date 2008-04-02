From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Wed, 2 Apr 2008 07:57:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804020713370.25100@wm7d.net>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: pierrick grasland <pierrick.grasland@gmail.com>
Cc: Horms <horms@vergenet.net>, lvs-devel@vger.kernel.org

On Wed, 2 Apr 2008, pierrick grasland wrote:

> So, in order to simplify my setup, I was hoping to 
> implement something which will allow ipvsadm to track 
> call-id, and not <ip:port> connections.

I notice that you've sent this e-mail to me personally. I 
hope you don't mind if I cc this reply to the lvs-devel 
list, as the people there will have ideas about this.

you're going where few people have gone. The various L7 
packages you mention associated with LVS are not in common 
use. I assume this is because they're difficult to set up 
(they're general) and noone needs them enough to bother.

However SIP keeps coming up on this list and lvs can't 
handle SIP out of the box, so something will have to be done 
about it.

> I have browse some sources (ktcpvs, ipvsadm, l7vsadm, 
> l7directord), but I'm actually lost. All these packages 
> allow some application level routing for HTTP, but are 
> based at differents levels (kernel for ktcpvs, user for 
> ipvsadm/l7vsadm, l7directord seems to be an addon for 
> configuration of l7vsadm and health check for realserver).

It's not obvious to me which, if any are suitable starting 
points, but you should know the code to get ideas.

I expect the best idea would be a sip helper, like the ftp 
helper module. It will have to know all about SIP and unlike 
the other L7 packages, would need little if any configuring. 
Presumably you could start with a module that recognises the 
UDP packets you've been using for tests. The ftp helper just 
looks at the tcpip headers. You'll have to look inside the 
packet. There's a u32 option to iptables that looks inside 
packets - you should find out how that works.

You're going to have to write a scheduler based on call-id 
as well. I like the -SH scheduler for for getting 
persistence based on CIP, rather than the standard LVS 
persistence code, which hangs if the client disappears.
I don't know if the call-id can be associated with an IP.

Horms has talked about a SIP helper (I think - at least he's 
talked about SIP). He may have even have some code.

Horms:

Other people have come and gone asking about SIP, but 
Pierrick seems to be taking more than a casual interest in 
getting SIP running under LVS. He has got the UDP connect 
packet to work under LVS, which is further than anyone else 
has gone. Got any ideas on how he should proceed?

Joe

>
> I hope you will be able to indicate which package can be a 
> good starting point, and some hints which can be useful.
>
> Thanks for your help,
>
>

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
