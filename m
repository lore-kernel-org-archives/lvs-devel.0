From: "Julius Volz" <juliusv@google.com>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 12:51:57 +0200
Message-ID: <f4845fc0803310351u1c666328h80e90a914fc32b91@mail.gmail.com>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
	 <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1206960719; bh=t0k+uex7euCz0IWujTg08VXK0l0=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=L0ewuIYDh7sOxuZFMXyQBbJsxoGUnbfW
	s6BXWJVM1j94eAMGiKiSkhAe2g8Uni51XDkZmmKNYzfCKfgibn/oSg==
In-Reply-To: <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: lvs-devel@vger.kernel.org

Hi Joe,

Thanks for the great feedback!

On Fri, Mar 28, 2008, Joseph Mack NA3T wrote:
>  There is an effort underway to move ipvs() from the LOCAL_IN
>  chain, where it currently sits for historical reasons, to a
>  better place. A better place is either PREROUTING or
>  FORWARD. Both hooks look OK at the moment. It is possible
>  that the location will be decided at run time. This work is
>  being done by Janusz, who is on this mailing list, but AFAIK
>  it's not in the kernel and hasn't had testing by selected
>  users. You should coordinate with him so that your codes are
>  compatible.

Ok, good to know, I will do that!

>  There is a problem with PMTU discovery when using LVS-Tun
>  (described in the HOWTO), which is currently handled (I
>  think) by iptables and an mss option. Part of the problem is
>  that the Linux networking stack doesn't do PMTU correctly.
>  At least be prepared for this problem. I don't know how easy
>  it would be to fix.

Thanks for the warning, I guess you are talking about this (and the
following points):

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-Tun.html#MTU

Does this have any special implications in the IPv6 case? The problem
looks pretty complicated and no one seems to completely understand it
;) I will keep it in mind for later though.

>  We don't have enough people using UDP to know how LVS should
>  handle UDP. There are problems with UDP (described in the
>  HOWTO). People are trying to setup SIP on LVS. With all the
>  ports involved in the protocol, I don't expect it will be
>  easy. I expect the only solution will be a module on the
>  director (like the ftp helper) that understands the SIP
>  protocol. It seems that multiport protocols are going to
>  become more common as coders try to get through ISPs who
>  think it's their business to throttle the internet.

Again, interesting info. Is there a specific relation to IPv6 though?

>  ipvs has an uneasy relationship with netfilter. ipvs
>  bypasses netfilter for speed. However in doing so, iptables
>  no longer works as users would reasonably expect (at least
>  for LVS-NAT). With cpus getting faster, relative to networks
>  (I think that's true), it may not hurt if ipvs is a little
>  slower, for more compatibility with netfilter. However the
>  speed of ipvs is a well regarded feature. *BSD has
>  loadbalancing but it's slow compared to ipvs, so we wouldn't
>  want to drop too much speed.

Aha, interesting. Could you explain a bit more for a newbie in what
ways IPVS "bypasses" netfilter? Other than that IPVS is basically a
Netfilter extension, it is still not really clear to me how other
Netfilter features are affected when using IPVS in combination with
them.

>  > 3) Currently, IPVS lives under .../net/ipv4/ipvs in the
>  > kernel, but much of the code is not IPv4-specific.
>
>  I expect this is all historical, from when ipvs was based on
>  masquerading code, rather than netfilter.

Ok.

>  > Any ideas on how to best refactor that common code to make
>  > it usable for both IPv4 or IPv6?
>
>  If you write it and are happy with it, we'll take your
>  scheme :-). Horms has been doing all the work on LVS for the
>  last couple of years, knows the code and has thought a
>  lot about where LVS should and shouldn't go. I'm sure he'll
>  have ideas on what's best.

Great.

>  > 4) How could this work be best split up into manageable
>  > chunks that could either be worked on serially or in
>  > parallel (by multiple developers)?
>
>  There hasn't been much developement on ipvs recently. The
>  original developer Wensong hasn't been active for a while
>  and Horms took over. Horms is the one who submits the new
>  code to the kernel. But Horms has been busy doing other
>  things and in the meantime ipvs is not getting a lot of
>  attention. So you'll be it if you take on the ipv6 job.

Wow, ok. Again, I don't have any experience with kernel coding, but I
will learn as much as I can!

>  > 5) Who else would be interested in parts of this effort or
>  > just in helping out when questions come up?
>
>  Anyone on this list will be happy to listen to anything you
>  have to say :-)

Great :)

>  good luck. Thanks for taking on the job.

Thank you very much!

Julius

--
Google Switzerland GmbH
