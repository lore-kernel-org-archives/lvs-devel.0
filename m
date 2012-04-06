From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: Re[2]: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has
 been registered
Date: Fri, 6 Apr 2012 11:22:13 +0200
Message-ID: <CA+1xoqe_VGuUaMCpWWz=gSBBmGu8cUha9qznzhy_jNCRknudBA@mail.gmail.com>
References: <6dfqp4f.85748eeb029b04c66ac5e143b62a5455@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type:content-transfer-encoding;
        bh=FJ0AJalg4iMl2guQHaGD19yL4XJ6124fdvEzOhhj+eY=;
        b=VXGk+gQxD35ScwLMUVeG7koSPgQpHfa29Ykks7Oggwqv0qjFvQinDLkyb5Bm+KyRse
         C1HN5lP1NoMK65zR/CFmxo8Ic50vzV/F5CF5i3U3hK8JqCCQCmxcyo5e8ErJmDKWdefi
         Ms+HQt4GWEu+HI3GCvZJdAxc6Uc8Yfmfz2sWAd7yo1J14rEqkIqlNllparyY4bmyliN6
         hX8PU3NgNDqQ/zjei6cPslHKY8UA1irYbDETrf8Au+iERFIi/uwdExfwaboWLvr3fGtb
         umwFcCx9GS/6ohI6hv1dAI9qpQLWZeX4NAm7nU3ZLitWQ/bMUZOZm5EBNaRsaw0Tt83r
         kv2Q==
In-Reply-To: <6dfqp4f.85748eeb029b04c66ac5e143b62a5455@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Apr 6, 2012 at 10:59 AM, Hans Schillstrom <hans@schillstrom.com=
> wrote:
> Hello Simon
>
>>---- Original Message ----
>>From: Simon Horman <horms@verge.net.au>
>>To: "Sasha Levin" <levinsasha928@gmail.com>
>>Cc: wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net, davem@davemloft=
=2Enet, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel=
=2Eorg, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org
>>Sent: Fri, Apr 6, 2012, 1:19 AM
>>Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has =
been registered
>>
>>On Thu, Apr 05, 2012 at 07:24:33PM -0400, Sasha Levin wrote:
>>> The registration of a protocol might fail, there were no checks
>>> and all registrations were assumed to be correct. This lead to
>>> NULL ptr dereferences when apps tried registering.
>>
>>Thanks, I will queue up this fix.
>>
>>Do you have a real-world example of this failing, if so it
>>might be worth pushing your change into stable.
>
> I don't think this is a big thing, the only thing that can cause it i=
s out of memory,
> and that will cause a "kernel death" anyway :-(
>
> here is the code :
>
> register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp=
)
> {
> ...
> =A0 =A0 =A0 =A0struct ip_vs_proto_data *pd =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kzalloc(sizeof(struct =
ip_vs_proto_data), GFP_ATOMIC);
>
> =A0 =A0 =A0 =A0if (!pd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
>

Considering that the allocation gfp flag here is GFP_ATOMIC (why is it
GFP_ATOMIC btw?), it might fail for a variety of reasons which may
occur when the system is "healthy", for example - if it needs disk I/O
to allocate.

Either way, you shouldn't be dereferencing NULL ptrs even when the
system is really low on memory.
