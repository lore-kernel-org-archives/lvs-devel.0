From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 06/15] ipv4: Merge ip_local_out and
 ip_local_out_sk
Date: Thu, 8 Oct 2015 11:38:56 +0200
Message-ID: <561639B0.8020902@6wind.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
 <1444157595-28816-6-git-send-email-ebiederm@xmission.com>
 <561530DB.10309@6wind.com> <877fmy5s6f.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <877fmy5s6f.fsf@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"; format="flowed"
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

Le 07/10/2015 22:39, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 06/10/2015 20:53, Eric W. Biederman a =C3=A9crit :
>>> It is confusing and silly hiding a paramater so modify all of
>>> the callers to pass in the appropriate socket or skb->sk if
>>> no socket is known.
>>>
>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>> ---
>> [snip]
>>> @@ -456,7 +456,7 @@ packet_routed:
>>>    	skb->priority =3D sk->sk_priority;
>>>    	skb->mark =3D sk->sk_mark;
>>>
>>> -	res =3D ip_local_out(skb);
>>> +	res =3D ip_local_out(sk, skb);
>> As stated in the comment at the top of this function (ip_queue_xmit(=
)), skb->sk
>> can be different from sk. See also commit b0270e91014d ("ipv4: add a=
 sock
>> pointer to ip_queue_xmit()").
>> Not sure if this change is right.
>
> Good catch.  This change should not have been buried in this patch. I=
t
> needs to be it's own separate bug fix.
>
> As I read the code we actually do want to pass sk not skb->sk into
> ip_local_out.  For all of the reasons that sk is potentially differen=
t
> from skb->sk already.
>
> The way I understand this is we have pushed an sk parameter through t=
he
> output path so that sk_mc_loop(sk) can be called with the tunnel's
> socket not whatever is on skb->sk.  This allows for looking to see if
> local multicast loopback is configured on the tunnels socket not on t=
he
> originating socket of the packet.
Ok, thank you for the explanation.
