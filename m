From: yunhong-cgl jiang <xintian1976@gmail.com>
Subject: Re: Long delay on estimation_timer causes packet latency
Date: Fri, 17 Apr 2020 09:56:06 -0700
Message-ID: <F48099A3-ECB3-46AF-8330-B829ED2ADA3F@gmail.com>
References: <D25792C1-1B89-45DE-9F10-EC350DC04ADC@gmail.com>
 <alpine.LFD.2.21.2004171029240.3962@ja.home.ssi.bg>
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.14\))
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=5vRyt3gyMvMWOByiQup7/iuoQyfsqpdRhoS1efdjEY4=;
        b=r96iYaAJUFqutvLlNPFb8i3j1V2Dc4shFIQjqagN+c4HoNWeaVzgEOSlDtF/nXoxKL
         4rl8ksUKanZyBWaTMkATLdET25r9HIQPScCqXELA3cNyylFog/fLtdWR2J2aD+Aot1YA
         uwzDq6E2MD1Fe/5FgD0dGmraCG6JeLOj7/OyHK2DIfWJbfzGImluPYqoqPSWmebwHv5Q
         iKppF+24I3/OXUS/3ulHsPzPByHZ9+gmoz9J4zWOJqfyl9mNR9vlRfthl3wJm6mGw3VN
         JMVkTgidHeBShG/JYVSsBUIJtXjX5RM3PMY0iQQDebm+PE6pl5ItFx7y8X87P4CVLeEr
         MIBw==
In-Reply-To: <alpine.LFD.2.21.2004171029240.3962@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Yunhong Jiang <yunhjiang@ebay.com>

Thanks for reply.

Yes, our patch changes the est_list to a RCU list. Will do more testing =
and send out the patch.

Thanks
=E2=80=94Yunhong


> On Apr 17, 2020, at 12:47 AM, Julian Anastasov <ja@ssi.bg> wrote:
>=20
>=20
> 	Hello,
>=20
> On Thu, 16 Apr 2020, yunhong-cgl jiang wrote:
>=20
>> Hi, Simon & Julian,
>> 	We noticed that on our kubernetes node utilizing IPVS, the =
estimation_timer() takes very long (>200sm as shown below). Such long =
delay on timer softirq causes long packet latency. =20
>>=20
>>          <idle>-0     [007] dNH. 25652945.670814: softirq_raise: =
vec=3D1 [action=3DTIMER]
>> .....
>>          <idle>-0     [007] .Ns. 25652945.992273: softirq_exit: vec=3D1=
 [action=3DTIMER]
>>=20
>> 	The long latency is caused by the big service number (>50k) and =
large CPU number (>80 CPUs),
>>=20
>> 	We tried to move the timer function into a kernel thread so that =
it will not block the system and seems solves our problem. Is this the =
right direction? If yes, we will do more testing and send out the RFC =
patch. If not, can you give us some suggestion?
>=20
> 	Using kernel thread is a good idea. For this to work, we can
> also remove the est_lock and to use RCU for est_list.
> The writers ip_vs_start_estimator() and ip_vs_stop_estimator() already
> run under common mutex __ip_vs_mutex, so they not need any
> synchronization. We need _bh lock usage in estimation_timer().
> Let me know if you need any help with the patch.
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

