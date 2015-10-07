From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 06/15] ipv4: Merge ip_local_out and ip_local_out_sk
Date: Wed, 07 Oct 2015 15:39:52 -0500
Message-ID: <877fmy5s6f.fsf@x220.int.ebiederm.org>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
	<1444157595-28816-6-git-send-email-ebiederm@xmission.com>
	<561530DB.10309@6wind.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <561530DB.10309@6wind.com> (Nicolas Dichtel's message of "Wed, 7
	Oct 2015 16:48:59 +0200")
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 06/10/2015 20:53, Eric W. Biederman a =C3=A9crit :
>> It is confusing and silly hiding a paramater so modify all of
>> the callers to pass in the appropriate socket or skb->sk if
>> no socket is known.
>>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
> [snip]
>> @@ -456,7 +456,7 @@ packet_routed:
>>   	skb->priority =3D sk->sk_priority;
>>   	skb->mark =3D sk->sk_mark;
>>
>> -	res =3D ip_local_out(skb);
>> +	res =3D ip_local_out(sk, skb);
> As stated in the comment at the top of this function (ip_queue_xmit()=
), skb->sk
> can be different from sk. See also commit b0270e91014d ("ipv4: add a =
sock
> pointer to ip_queue_xmit()").
> Not sure if this change is right.

Good catch.  This change should not have been buried in this patch. It
needs to be it's own separate bug fix.

As I read the code we actually do want to pass sk not skb->sk into
ip_local_out.  For all of the reasons that sk is potentially different
from skb->sk already.

The way I understand this is we have pushed an sk parameter through the
output path so that sk_mc_loop(sk) can be called with the tunnel's
socket not whatever is on skb->sk.  This allows for looking to see if
local multicast loopback is configured on the tunnels socket not on the
originating socket of the packet.

I am going to respin my series with that change made into a separate bu=
g
fix, that can potentially be backported.

Eric

