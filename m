From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH 2/3] IPVS: make friends with nf_conntrack
Date: Thu, 3 Sep 2009 12:22:53 +0200
Message-ID: <b5ddba180909030322h42aa9337o4c20696b86029b71@mail.gmail.com>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
	 <20090902101538.11561.11911.stgit@jazzy.zrh.corp.google.com>
	 <4A9E8788.1090901@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1251973378; bh=uYKukBnFnGae9/Iv+uSYbIvKRuA=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=nGL0xmWgpp8WlUedk7
	pu+IxEZNz4tm54P8trxpTn9gy+SjNv4xy3RpgbCcrJJEYEeixNyZ0A3BoXITEIzubKJ
	w==
In-Reply-To: <4A9E8788.1090901@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

On Wed, Sep 2, 2009 at 16:56, Patrick McHardy<kaber@trash.net> wrote:
> Hannes Eder wrote:
>> Update the nf_conntrack tuple in reply direction, as we will see
>> traffic from the real server (RIP) to the client (CIP). =A0Once this=
 is
>> done we can use netfilters SNAT in POSTROUTING, especially with
>> xt_ipvs, to do source NAT, e.g.:
>>
>> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 -=
-vport 8080 \
>>> -j SNAT --to-source 192.168.10.10
>>
>
>> +static void
>> +ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
>> +{
>> + =A0 =A0 struct nf_conn *ct =3D (struct nf_conn *)skb->nfct;
>> +
>> + =A0 =A0 if (ct =3D=3D NULL || ct =3D=3D &nf_conntrack_untracked ||
>> + =A0 =A0 =A0 =A0 nf_ct_is_confirmed(ct))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* The connection is not yet in the hashtable, so we upd=
ate it.
>> + =A0 =A0 =A0* CIP->VIP will remain the same, so leave the tuple in
>> + =A0 =A0 =A0* IP_CT_DIR_ORIGINAL untouched. =A0When the reply comes=
 back from the
>> + =A0 =A0 =A0* real-server we will see RIP->DIP.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3 =3D cp->daddr;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* This will also take care of UDP and other protocols.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u.tcp.port =3D cp=
->dport;
>> +}
>
> How does IPVS interact with conntrack helpers? If it does actually
> intend to use them (which will happen automatically), it might make
> sense to use nf_conntrack_alter_reply(), which will perform a new
> helper lookup based on the changed tuple.

Good point, I'll use nf_conntrack_alter_reply().  IHMO IPVS only deals
with ftp in a special way, I think something need to be done there as
well, I'll investigate that.
