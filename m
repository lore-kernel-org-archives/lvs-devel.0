From: Siim =?iso-8859-15?Q?P=F5der?= <siim@p6drad-teel.net>
Subject: Re: [PATCH 1/2] ipvs: load balance IPv4 connections from a local 
     process
Date: Fri, 5 Sep 2008 08:49:52 +0300 (EEST)
Message-ID: <60dee71e238f7fa03da7bc5338ec4bf5.squirrel@p6drad-teel.net>
References: <20080905013609.GD14128@verge.net.au>
    <Pine.LNX.4.58.0809050750550.2831@u.domain.uli>
Reply-To: siim@p6drad-teel.net
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0809050750550.2831@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Siim =?iso-8859-15?Q?P=F5der?= <siim@p6drad-teel.net>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>

Hi

> 	TCP checksum is not optional, why this change appeared?

The new packets that we handle are on the loopback device and no checks=
ums
appear to be generated there. I initially changed the condition to chec=
k
for loopback device (which we could do), but checking udp code found th=
at
it already handled it by checking zero checksum, hence the same
implementation in tcp code.

>> Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-03
>> 10:56:05.000000000 +1000
>> +++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-03
>> 11:24:26.000000000 +1000
>> @@ -166,7 +166,7 @@ tcp_snat_handler(struct sk_buff *skb,
>>  	tcph->source =3D cp->vport;
>>
>>  	/* Adjust TCP checksums */
>> -	if (!cp->app) {
>> +	if (!cp->app && (tcph->check !=3D 0)) {
>>  		/* Only port and addr are changed, do fast csum update */
>>  		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
>>  				     cp->dport, cp->vport);
>> @@ -235,7 +235,7 @@ tcp_dnat_handler(struct sk_buff *skb,
>>  	/*
>>  	 *	Adjust TCP checksums
>>  	 */
>> -	if (!cp->app) {
>> +	if (!cp->app && (tcph->check !=3D 0)) {
>>  		/* Only port and addr are changed, do fast csum update */
>>  		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
>>  				     cp->vport, cp->dport);
>> --

--=20
Siiralt Teie,
Elektromehaaniline P=F5der

