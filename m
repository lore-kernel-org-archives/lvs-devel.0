From: "Julius Volz" <juliusv@google.com>
Subject: Re: Getting IPVS and Netfilter SNAT to play together
Date: Wed, 24 Sep 2008 14:44:15 +0200
Message-ID: <f4845fc0809240544x3ed6a65emdbe440ecd840b122@mail.gmail.com>
References: <f4845fc0809230313y14e69dc6s7b5e3e2f33f6beae@mail.gmail.com>
	 <alpine.LNX.1.10.0809230827410.29878@fbirervta.pbzchgretzou.qr>
	 <f4845fc0809230545n6c879a7eg7214b0a3b3db61a3@mail.gmail.com>
	 <f4845fc0809230613l68c1ba90s16e5482479bd3c9c@mail.gmail.com>
	 <alpine.LNX.1.10.0809230920330.29878@fbirervta.pbzchgretzou.qr>
	 <f4845fc0809230654o159334d6p76952663f00cb881@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1222260259; bh=ZBwtWIcMdAg0GFHr1PIBlnORTDQ=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References:X-GMailtapped-By; b=AVbmG6RF+lI4pJz
	I6CUMZiQk337WePwssjpRKpOgkFesYMI+PFZsOy86cmLdRP17OmxYI/pbaOyuEhzKN+
	9Gjw==
In-Reply-To: <f4845fc0809230654o159334d6p76952663f00cb881@mail.gmail.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org

Didn't include lvs-devel in CC of the original message, adding it now...

On Tue, Sep 23, 2008 at 3:54 PM, Julius Volz <juliusv@google.com> wrote:
> On Tue, Sep 23, 2008 at 3:21 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>
>> On Tuesday 2008-09-23 09:13, Julius Volz wrote:
>>>
>>>Ok, the SYN/ACK from the backend is logged as --cstate INVALID in
>>>PREROUTING and INPUT. This means that Netfilter thinks it doesn't
>>>belong to any connection, although it just SNATed the SYN to the
>>>backend correctly? Hmm... how can this be?
>>
>> That probably means skb->nfct is lost (set to NULL, which is what INVALID
>> indicates) after SNAT (PREROUTING), when IPVS kicks in.
>
> But at PREROUTING, the skb hasn't seen any part of IPVS yet. And the
> prior SNAT for the SYN packet happened in POSTROUTING after all of
> IPVS was finished. Basically, there should be no IPVS involved from
> the time that the SYN is correctly SNATed and the time that the
> SYN/ACK is not. Please correct me if I'm missing something here...

Ok, after lots of debugging, I've found the problem and got SNAT
working with IPVS (in a very hacky way).

The problem was that Netfilter already assigns a conntrack entry (in
skb->nfct) to the CIP->VIP SYN packet in PREROUTING. This contains a
tuple which contains source and destination addresses as seen by
Netfilter during PREROUTING (before IPVS). IPVS then modifies the
destination address without updating the associated skb->nfct entry.
Later, Netfilter SNAT in POSTROUTING finds the already assigned tuple
and updates it with the new source address, but the destination
address changed by IPVS is never updated in this tuple. This is why
this wrong conntrack entry does not match the SYN/ACK packet returning
from the backend server.

So as a proof of concept for IPVS SNAT, it is enough to remove the
ip_vs_post_routing() function (to let Netfilter handle anything at all
in POSTROUTING) and put a simple "skb->nfct = NULL;" into the IPVS NAT
transmitter function, ip_vs_nat_xmit(), to let the conntrack tuple be
regenerated in by Netfilter POSTROUTING. Of course, this is a memory
leak, the conntrack hash entries aren't removed, etc.

I guess to do this correctly, we should probably update the skb->nfct
entry in IPVS while doing our manual DNAT?

I realize there's a big patch integrating IPVS with conntrack
(http://www.ssi.bg/~ja/nfct/) in some way, but it seems like that does
much more than would be needed for SNAT.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
