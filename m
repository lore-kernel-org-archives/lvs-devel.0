Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBDBF21ADA9;
	Tue, 20 May 2025 01:52:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747705955; cv=none; b=nsyccv0ua216UmoCW/A6lW6/58mjf8nk+lW7z1BGfXKjNW6K3Va3+9jcYK5nmaifITBfbEKbh07C3vJnOI69jn9xzNsK/ZjtyVHz294MjF60EzqIRHhlLi9jg9g+ErgEH7aRv3CXwWQj4RNSBihtMu3unHn38+ikNxF/UVeuM7E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747705955; c=relaxed/simple;
	bh=hq7tG6InQiMtDLFIKCTHEe2KHxUYZrzTpjLuQAf3PBY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=CxzGTer1Na/sbq7HdANsTO5BqK9CK6Yg9RQwUrUqqY1KOpMtHQt5cba1vYUiIt/8S+oVizk9dNdDIRiFZgQxsQPvFRzFB7UWAvxefbK+Yd8gJY/coYzjqH68e7r0TWRuegPuww4EBNZIexWN95CPKjS5w2eDhHKt1HddHLmYa9k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=MehRgb68; arc=none smtp.client-ip=209.85.208.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MehRgb68"
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-600210e4219so7516512a12.0;
        Mon, 19 May 2025 18:52:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1747705952; x=1748310752; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=mT7APD0PPLceAEMsL11QVrKRuvd0HX5iowg9HBwBVQA=;
        b=MehRgb68MuMVtsnx5n5tfXhIHFPI2l1DZnT5siTAFbhAI6hfbAKlM7YYvwqcULvAy5
         PQNoKUrxpOtyT6RIp39QfLrZdJ0slgR+epbCs+teLSNYFcx/Y8jRsIi59q9ijFhhzzjL
         xwC99a4u869nUcZ8iFTEo9OB6y8s7QGNtVjMxl0+i2OkEsD7rJDliOgFUFtD6CMQB3bV
         T03caZzOXHoL1v9iho6e86UNKwX9ozT/x8DyGcE5D0CaHCf5uD5VoSuqMbIfWHdT6hKl
         iiHWUrMKKTqnKUd2NPpolBXCxkgM/ykBgZtxyy24UDgF5FYvalorEkSKm5jASQwxo1fw
         M/QQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747705952; x=1748310752;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=mT7APD0PPLceAEMsL11QVrKRuvd0HX5iowg9HBwBVQA=;
        b=ReVQlUNKwCfAaBOnPoMvxGPFImtOahxtbblmhVGoNg3DtLmWPracMOlaP8pX+nlgw6
         z3FwXeVYhBPyjHiynFONwmMbmysUvGIO7K78s5iCiPJaRPI+0NoC52kF9n7Gq5/OxNIT
         qHqZ9xL75NqcEmHidzE0uvoINkRYEGFfz57ipMwjJ8EmNCW4yiRKWeXzsB3ddPBuwQ+q
         9lSBDikzra86b1jc7DXXSiC16fQPad4B2PBWmuURLSGY8fHGMc3fMTXrbZVY+3DhdL7p
         PplCUjkD6tcJhMCQ205aHY0LeAXC7fYM2/6SpTS/ly/dUumCGAWURlQ3C3fOhm0v0+kF
         GeBA==
X-Forwarded-Encrypted: i=1; AJvYcCV+xarS9Wgc7CJaLmPh2GDJtOXpPB4oXsrrw4FiD/R8iFToCX6qAD3MW7ZSzcL4xy4ItHrqEsFkTIk=@vger.kernel.org, AJvYcCVXyPK4K/NPkBWqitCAU44rhutIWuJpIO7P02PEbPMyl/5sV2yClhH9ACUBKXA5V4OO2wPHQXED@vger.kernel.org
X-Gm-Message-State: AOJu0YwscnkY78NU8Lf9gA3LxUnwZi+YoIDe02UkJ8LtKyeP06Tp8a8+
	lWkKhcYBdRjP/NjA2VdgdihuXL+AjTlztGBxzxOi9T7A1NZKmxpUI3RP2Y0rw9eHABqcSJpMaK9
	MuQiEdTgAJlLaNq7gLB3gQQ0kpY2qlygFpEwUWN8=
X-Gm-Gg: ASbGncs7rGPYOLHBZ2/9oLO/au8pFk5ShVwGp5yySDpEaia1K2Jzz20d8LTal40u40P
	A4koe14MrT/UbIXTFAp0mSeY2oGjAgPVlNY8a8K5B5ZqNaLgoQXQwtKnGCSIw8aA2HQcsFHwQ0k
	edsgrKHjUteRS+7BuBa74RPAWpqsRu0+JQKjc=
X-Google-Smtp-Source: AGHT+IEZH7FDonKk41E9BCvtsQCjU48p1JLXnrB8RAk7TOAQPce97ykfJUP/PGKpomrSZ+qQmamKM5MlAGvYKqxcKek=
X-Received: by 2002:a17:907:7e9a:b0:ad5:1d0c:1b90 with SMTP id
 a640c23a62f3a-ad52f321ba1mr1333541766b.11.1747705951614; Mon, 19 May 2025
 18:52:31 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20250519103203.17255-1-djduanjiong@gmail.com> <aef5ec1d-c62f-9a1c-c6f3-c3e275494234@ssi.bg>
In-Reply-To: <aef5ec1d-c62f-9a1c-c6f3-c3e275494234@ssi.bg>
From: Duan Jiong <djduanjiong@gmail.com>
Date: Tue, 20 May 2025 09:52:19 +0800
X-Gm-Features: AX0GCFvmVIbUuVZBDlwxsinqEMdQzBM2Guin-Bkgk50Hstn0rBGV2TwiA7wFJn4
Message-ID: <CALttK1Sn=D4x81NpEq1ELHoXnEaiMboYBzYeOUX8qKHzDDxk0A@mail.gmail.com>
Subject: Re: [PATCH] ipvs: skip ipvs snat processing when packet dst is not vip
To: Julian Anastasov <ja@ssi.bg>
Cc: pablo@netfilter.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, May 20, 2025 at 4:11=E2=80=AFAM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
>         Adding lvs-devel@ to CC...
>
> On Mon, 19 May 2025, Duan Jiong wrote:
>
> > Now suppose there are two net namespaces, one is the server and
> > its ip is 192.168.99.4, the other is the client and its ip
> > is 192.168.99.5, and the other is configured with ipvs vip
> > 192.168.99.6 in the host net namespace, configuring ipvs with
> > the backend 192.168.99.5.
> >
> > Also configure
> > iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE
> > to avoid packet loss when accessing with the specified
> > source port.
>
>         May be I don't quite understand why the MASQUERADE
> rule is used...

If nat is not configured, __nf_conntrack_confirm drops packets due to
tuple conflicts.

I'll post my reproduction method later on.

>
> >
> > First we use curl --local-port 15280 to specify the source port
> > to access the vip, after the request is completed again use
> > curl --local-port 15280 to specify the source port to access
> > 192.168.99.5, this time the request will always be stuck in
> > the main.
> >
> > The packet sent by the client arrives at the server without
> > any problem, but ipvs will process the packet back from the
> > server with the wrong snat for vip, and at this time, since
> > the client will directly rst after receiving the packet, the
> > client will be stuck until the vip ct rule on the host
> > times out.
> >
> > Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_core.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
> > index c7a8a08b7308..98abe4085a11 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1260,6 +1260,8 @@ handle_response(int af, struct sk_buff *skb, stru=
ct ip_vs_proto_data *pd,
> >               unsigned int hooknum)
> >  {
> >       struct ip_vs_protocol *pp =3D pd->pp;
> > +     enum ip_conntrack_info ctinfo;
> > +     struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
> >
> >       if (IP_VS_FWD_METHOD(cp) !=3D IP_VS_CONN_F_MASQ)
> >               goto after_nat;
> > @@ -1270,6 +1272,12 @@ handle_response(int af, struct sk_buff *skb, str=
uct ip_vs_proto_data *pd,
> >               goto drop;
> >
> >       /* mangle the packet */
> > +     if (ct !=3D NULL &&
> > +         hooknum =3D=3D NF_INET_FORWARD &&
> > +         !ip_vs_addr_equal(af,
> > +                 &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3,
> > +                 &cp->vaddr))
> > +             return NF_ACCEPT;
>
>         Such check will prevent SNAT for active FTP connections
> because their original direction is from real server to client.
> In which case ip_vs_addr_equal will see difference? When
> Netfilter creates new connection for packet from real server?
> It does not look good IPVS connection to be DNAT-ed but not
> SNAT-ed.
>
>         May be you can explain better what IPs/ports are present in
> the transferred packets.
>
> >       if (pp->snat_handler &&
> >           !SNAT_CALL(pp->snat_handler, skb, pp, cp, iph))
> >               goto drop;
> > --
> > 2.32.1 (Apple Git-133)
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>


1.  setup environment

[root@centos9s vagrant]# cat setup.sh
#!/bin/bash

ip netns add server
ip link add svrh type veth peer name svr
ip link set svr netns server
ip link set svrh up
ip link set dev svrh address ee:ee:ee:ee:ee:ee
ip netns exec server ip link set svr up
ip netns exec server ip addr add 192.168.99.4/32 dev svr
ip netns exec server ip route add 169.254.1.1 dev svr scope link
ip netns exec server ip route add default via 169.254.1.1 dev svr
ip netns exec server ip neigh add 169.254.1.1 lladdr ee:ee:ee:ee:ee:ee
dev svr nud permanent
ip route add 192.168.99.4/32 dev svrh

ip netns add client
ip link add clih type veth peer name cli
ip link set cli netns client
ip link set clih up
ip link set dev clih address ee:ee:ee:ee:ee:ee
ip netns exec client ip link set cli up
ip netns exec client ip addr add 192.168.99.5/32 dev cli
ip netns exec client ip route add 169.254.1.1 dev cli scope link
ip netns exec client ip route add default via 169.254.1.1 dev cli
ip netns exec client ip neigh add 169.254.1.1 lladdr ee:ee:ee:ee:ee:ee
dev cli nud permanent
ip route add 192.168.99.5/32 dev clih

ip addr add 192.168.99.6/32 dev lo
ipvsadm -A -t 192.168.99.6:8080 -s rr
ipvsadm -a -t 192.168.99.6:8080 -r 192.168.99.4:8080 -m

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 >  /proc/sys/net/ipv4/vs/conntrack
iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE

2. start server
ip netns exec server python -m http.server 8080

3. curl vip
ip netns exec client curl --local-port 15280 http://192.168.99.6:8080

4. curl rs
ip netns exec client curl --local-port 15280 http://192.168.99.4:8080

Here are the ct rules for executing curl and the tcpdump capture.

[root@centos9s vagrant]# tcpdump -s0 -nn -i clih
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on clih, link-type EN10MB (Ethernet), snapshot length 262144 byte=
s
01:50:14.328558 IP6 fe80::fc0e:fff:fef8:7c05 > ff02::2: ICMP6, router
solicitation, length 16
01:50:28.430769 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [S],
seq 614710449, win 64240, options [mss 1460,sackOK,TS val 2654895687
ecr 0,nop,wscale 7], length 0
01:50:28.431026 ARP, Request who-has 192.168.99.5 tell 192.168.99.6, length=
 28
01:50:28.431034 ARP, Reply 192.168.99.5 is-at fe:0e:0f:f8:7c:05, length 28
01:50:28.431035 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
seq 3593264529, ack 614710450, win 65160, options [mss 1460,sackOK,TS
val 4198589191 ecr 2654895687,nop,wscale 7], length 0
01:50:28.431048 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
ack 1, win 502, options [nop,nop,TS val 2654895687 ecr 4198589191],
length 0
01:50:28.431683 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [P.],
seq 1:82, ack 1, win 502, options [nop,nop,TS val 2654895688 ecr
4198589191], length 81: HTTP: GET / HTTP/1.1
01:50:28.431709 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [.],
ack 82, win 509, options [nop,nop,TS val 4198589192 ecr 2654895688],
length 0
01:50:28.434072 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [P.],
seq 1:157, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
2654895688], length 156: HTTP: HTTP/1.0 200 OK
01:50:28.434083 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
ack 157, win 501, options [nop,nop,TS val 2654895690 ecr 4198589194],
length 0
01:50:28.434166 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [P.],
seq 157:1195, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
2654895690], length 1038: HTTP
01:50:28.434171 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
ack 1195, win 501, options [nop,nop,TS val 2654895690 ecr 4198589194],
length 0
01:50:28.434221 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [F.],
seq 1195, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
2654895690], length 0
01:50:28.434669 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [F.],
seq 82, ack 1196, win 501, options [nop,nop,TS val 2654895691 ecr
4198589194], length 0
01:50:28.434712 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [.],
ack 83, win 509, options [nop,nop,TS val 4198589195 ecr 2654895691],
length 0
01:50:33.158284 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236082988
ecr 0,nop,wscale 7], length 0
01:50:33.158429 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
val 4198593919 ecr 2236082988,nop,wscale 7], length 0
01:50:33.158496 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
seq 886133764, win 0, length 0
01:50:34.168530 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236083999
ecr 0,nop,wscale 7], length 0
01:50:34.168722 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
val 4198594929 ecr 2236082988,nop,wscale 7], length 0
01:50:34.168754 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
val 4198594929 ecr 2236082988,nop,wscale 7], length 0
01:50:34.168751 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
seq 886133764, win 0, length 0
01:50:34.168769 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
seq 886133764, win 0, length 0
01:50:36.216624 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
val 4198596977 ecr 2236082988,nop,wscale 7], length 0
01:50:36.216626 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236086047
ecr 0,nop,wscale 7], length 0
01:50:36.216678 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
seq 886133764, win 0, length 0
01:50:36.216690 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
val 4198596977 ecr 2236082988,nop,wscale 7], length 0
01:50:36.216693 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
seq 886133764, win 0, length 0
^C
28 packets captured
28 packets received by filter
0 packets dropped by kernel
[root@centos9s vagrant]# cat^C
[root@centos9s vagrant]# cat /proc/net/nf_conntrack | grep 15280
ipv4     2 tcp      6 7 CLOSE src=3D192.168.99.5 dst=3D192.168.99.6
sport=3D15280 dport=3D8080 src=3D192.168.99.4 dst=3D192.168.99.6 sport=3D80=
80
dport=3D15280 [ASSURED] mark=3D0 secctx=3Dsystem_u:object_r:unlabeled_t:s0
zone=3D0 use=3D2
ipv4     2 tcp      6 53 SYN_RECV src=3D192.168.99.5 dst=3D192.168.99.4
sport=3D15280 dport=3D8080 src=3D192.168.99.4 dst=3D192.168.99.6 sport=3D80=
80
dport=3D1279 mark=3D0 secctx=3Dsystem_u:object_r:unlabeled_t:s0 zone=3D0 us=
e=3D2
