From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Making IPVS work with IPv6
Date: Fri, 28 Mar 2008 09:23:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org

On Fri, 28 Mar 2008, Julius Volz wrote:

> Hi LVS devs,
>
> I'm currently interning at Google Zurich and we are very 
> interested in porting IPVS to IPv6. Indeed, I will 
> probably dedicate 60-70% of my time to that cause for the 
> next 5 months to come.

wonderful. Thanks

> 1) It looks as though there is no current effort on the 
> way to do this port, right?

correct.

> 2) Are there any serious technical or political roadblocks 
> to this we are not seeing?

There is an effort underway to move ipvs() from the LOCAL_IN 
chain, where it currently sits for historical reasons, to a 
better place. A better place is either PREROUTING or 
FORWARD. Both hooks look OK at the moment. It is possible 
that the location will be decided at run time. This work is 
being done by Janusz, who is on this mailing list, but AFAIK 
it's not in the kernel and hasn't had testing by selected 
users. You should coordinate with him so that your codes are 
compatible.

There is a problem with PMTU discovery when using LVS-Tun 
(described in the HOWTO), which is currently handled (I 
think) by iptables and an mss option. Part of the problem is 
that the Linux networking stack doesn't do PMTU correctly.
At least be prepared for this problem. I don't know how easy 
it would be to fix.

We don't have enough people using UDP to know how LVS should 
handle UDP. There are problems with UDP (described in the 
HOWTO). People are trying to setup SIP on LVS. With all the 
ports involved in the protocol, I don't expect it will be 
easy. I expect the only solution will be a module on the 
director (like the ftp helper) that understands the SIP 
protocol. It seems that multiport protocols are going to 
become more common as coders try to get through ISPs who 
think it's their business to throttle the internet.

ipvs has an uneasy relationship with netfilter. ipvs 
bypasses netfilter for speed. However in doing so, iptables 
no longer works as users would reasonably expect (at least 
for LVS-NAT). With cpus getting faster, relative to networks 
(I think that's true), it may not hurt if ipvs is a little 
slower, for more compatibility with netfilter. However the 
speed of ipvs is a well regarded feature. *BSD has 
loadbalancing but it's slow compared to ipvs, so we wouldn't 
want to drop too much speed.

> 3) Currently, IPVS lives under .../net/ipv4/ipvs in the 
> kernel, but much of the code is not IPv4-specific.

I expect this is all historical, from when ipvs was based on 
masquerading code, rather than netfilter.

> Any ideas on how to best refactor that common code to make 
> it usable for both IPv4 or IPv6?

If you write it and are happy with it, we'll take your 
scheme :-). Horms has been doing all the work on LVS for the 
last couple of years, knows the code and has thought a 
lot about where LVS should and shouldn't go. I'm sure he'll 
have ideas on what's best.

> 4) How could this work be best split up into manageable 
> chunks that could either be worked on serially or in 
> parallel (by multiple developers)?

There hasn't been much developement on ipvs recently. The 
original developer Wensong hasn't been active for a while 
and Horms took over. Horms is the one who submits the new 
code to the kernel. But Horms has been busy doing other 
things and in the meantime ipvs is not getting a lot of 
attention. So you'll be it if you take on the ipv6 job.

> 5) Who else would be interested in parts of this effort or 
> just in helping out when questions come up?

Anyone on this list will be happy to listen to anything you 
have to say :-)

> So I've been looking at the code for a couple of days now 
> and some parts I understand well, others I don't get at 
> all, but I hope to change that soon ;)

good luck. Thanks for taking on the job.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
