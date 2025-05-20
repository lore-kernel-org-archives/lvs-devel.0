Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73D401ACECE;
	Tue, 20 May 2025 13:28:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747747691; cv=none; b=OgXQcJyDSpFPcFVhxJuc2on1P1WziN5WZ4jvqbM4mv758QTWFKC/7vOhpNPbbLJQ0idlpVo4Z/wx5Dh640xMPTF6yojyyBe/OCxWQB7gZW6jHO/4OFjQLbjtPOPryvV9EhFoapzI9j0Qo8/EXzUVYFf0Irr5lSb6wNVcLyA9qXg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747747691; c=relaxed/simple;
	bh=cZ9R0ETre+tBmvp0DuUki4vor5qGjOvtI+u6OxR7Q3k=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=GiJ/ho4FCdrx++4sv0/VW3/GhhKQ80j6r7ekZWzr2FywmH6A7jv0HcnVBiLPKXqCVsWwMmXfT4tQTtShw2NkF1g2vJ1fioh4+wVkCCFrcBC0Z370aUUi7G9ECp6DUME3ywIW6ESyujpPhMi5DZ/HDnwyjiClIynailg0zw/GCXk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=A41bClPH; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="A41bClPH"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6D7C522CAD;
	Tue, 20 May 2025 16:28:03 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=sX/x59Qjev8GzAbAiGc8Xuv/PXjNhfvHwBJQSdNyR3k=; b=A41bClPH7Jbh
	fwkV+NZads5+ctviAIr3P3V2ICroLGFrs7JfBjaIGruh4vH8MEX4axCdjgY6Km3p
	83fTlbwi0JQ73Th+csfyViMEmAqy3QMC3yrA7v6piB/KxKs4+vTH87zn1vGU8RbO
	UvKpYsCvOxHYU7EY0CYDthYW2KGdPHwZaiU9EGgTgPvnbJBcCZy2izTxVSZb3P8+
	jVJAXwR/gYD5z+qizBqObw/NxXKsWvdIB9i4GzDtNcjpR53ZtMdeeAQTwuSL+Dfl
	2XpP1LzV3swCtvUh0evRO0k6WdUy8I2tW5rAJ6GzMc4XtRtivZsL0agS6Rhc3eiy
	W9KpVIwD7kRNzV2e5pIbGnrJ8xBqpHG7MxoUIZ0RbZWLNmqvKXfTBmNX8sCBqh3r
	uaigUSyKDjdOiFdn6rXtHm/jnwjjRrln2Jm+UpDmwZmE2KDJYDDXOTwO4kxmM4Br
	mKhI0Nzwcf4SOCXPBvmpN2OjILOgVVmznz2MfU8HGUQqKjvvRDy2PB/9Wvz4UYtZ
	Us4Mwtci0hC219UkePLuvlv/PQY3w6By86jK4jhFvQacCpxB5K8/eEzAofEYKVDA
	hWP0cJGueJT4vUcx9I0evsaQfBMSIM/Czfu4r7rhfZEsp+2XUsLmt7KDHRKDdDRq
	HQyqtgKyueBIKKfMZ9G0dxBVqYAJM0k=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 20 May 2025 16:28:02 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8E24160471;
	Tue, 20 May 2025 16:28:01 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 54KDRx0J022552;
	Tue, 20 May 2025 16:27:59 +0300
Date: Tue, 20 May 2025 16:27:59 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Duan Jiong <djduanjiong@gmail.com>
cc: pablo@netfilter.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Subject: Re: [PATCH] ipvs: skip ipvs snat processing when packet dst is not
 vip
In-Reply-To: <CALttK1Sn=D4x81NpEq1ELHoXnEaiMboYBzYeOUX8qKHzDDxk0A@mail.gmail.com>
Message-ID: <df6af9cc-35ff-5c3e-3e67-ed2f93a17691@ssi.bg>
References: <20250519103203.17255-1-djduanjiong@gmail.com> <aef5ec1d-c62f-9a1c-c6f3-c3e275494234@ssi.bg> <CALttK1Sn=D4x81NpEq1ELHoXnEaiMboYBzYeOUX8qKHzDDxk0A@mail.gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 20 May 2025, Duan Jiong wrote:

> 1.  setup environment
> 
> [root@centos9s vagrant]# cat setup.sh
> #!/bin/bash
> 
> ip netns add server
> ip link add svrh type veth peer name svr
> ip link set svr netns server
> ip link set svrh up
> ip link set dev svrh address ee:ee:ee:ee:ee:ee
> ip netns exec server ip link set svr up
> ip netns exec server ip addr add 192.168.99.4/32 dev svr
> ip netns exec server ip route add 169.254.1.1 dev svr scope link
> ip netns exec server ip route add default via 169.254.1.1 dev svr
> ip netns exec server ip neigh add 169.254.1.1 lladdr ee:ee:ee:ee:ee:ee
> dev svr nud permanent
> ip route add 192.168.99.4/32 dev svrh
> 
> ip netns add client
> ip link add clih type veth peer name cli
> ip link set cli netns client
> ip link set clih up
> ip link set dev clih address ee:ee:ee:ee:ee:ee
> ip netns exec client ip link set cli up
> ip netns exec client ip addr add 192.168.99.5/32 dev cli
> ip netns exec client ip route add 169.254.1.1 dev cli scope link
> ip netns exec client ip route add default via 169.254.1.1 dev cli
> ip netns exec client ip neigh add 169.254.1.1 lladdr ee:ee:ee:ee:ee:ee
> dev cli nud permanent
> ip route add 192.168.99.5/32 dev clih
> 
> ip addr add 192.168.99.6/32 dev lo
> ipvsadm -A -t 192.168.99.6:8080 -s rr
> ipvsadm -a -t 192.168.99.6:8080 -r 192.168.99.4:8080 -m
> 
> echo 1 > /proc/sys/net/ipv4/ip_forward
> echo 1 >  /proc/sys/net/ipv4/vs/conntrack
> iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE
> 
> 2. start server
> ip netns exec server python -m http.server 8080
> 
> 3. curl vip
> ip netns exec client curl --local-port 15280 http://192.168.99.6:8080
> 
> 4. curl rs
> ip netns exec client curl --local-port 15280 http://192.168.99.4:8080
> 
> Here are the ct rules for executing curl and the tcpdump capture.
> 
> [root@centos9s vagrant]# tcpdump -s0 -nn -i clih
> dropped privs to tcpdump
> tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
> listening on clih, link-type EN10MB (Ethernet), snapshot length 262144 bytes
> 01:50:14.328558 IP6 fe80::fc0e:fff:fef8:7c05 > ff02::2: ICMP6, router
> solicitation, length 16

	Client correctly connects to VIP:

> 01:50:28.430769 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [S],
> seq 614710449, win 64240, options [mss 1460,sackOK,TS val 2654895687
> ecr 0,nop,wscale 7], length 0
> 01:50:28.431026 ARP, Request who-has 192.168.99.5 tell 192.168.99.6, length 28
> 01:50:28.431034 ARP, Reply 192.168.99.5 is-at fe:0e:0f:f8:7c:05, length 28
> 01:50:28.431035 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> seq 3593264529, ack 614710450, win 65160, options [mss 1460,sackOK,TS
> val 4198589191 ecr 2654895687,nop,wscale 7], length 0
> 01:50:28.431048 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
> ack 1, win 502, options [nop,nop,TS val 2654895687 ecr 4198589191],
> length 0
> 01:50:28.431683 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [P.],
> seq 1:82, ack 1, win 502, options [nop,nop,TS val 2654895688 ecr
> 4198589191], length 81: HTTP: GET / HTTP/1.1
> 01:50:28.431709 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [.],
> ack 82, win 509, options [nop,nop,TS val 4198589192 ecr 2654895688],
> length 0
> 01:50:28.434072 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [P.],
> seq 1:157, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
> 2654895688], length 156: HTTP: HTTP/1.0 200 OK
> 01:50:28.434083 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
> ack 157, win 501, options [nop,nop,TS val 2654895690 ecr 4198589194],
> length 0
> 01:50:28.434166 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [P.],
> seq 157:1195, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
> 2654895690], length 1038: HTTP
> 01:50:28.434171 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
> ack 1195, win 501, options [nop,nop,TS val 2654895690 ecr 4198589194],
> length 0
> 01:50:28.434221 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [F.],
> seq 1195, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
> 2654895690], length 0
> 01:50:28.434669 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [F.],
> seq 82, ack 1196, win 501, options [nop,nop,TS val 2654895691 ecr
> 4198589194], length 0
> 01:50:28.434712 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [.],
> ack 83, win 509, options [nop,nop,TS val 4198589195 ecr 2654895691],
> length 0

	But the following packet is different from your
initial posting. Why client connects directly to the real server?
Is it allowed to have two conntracks with equal reply tuple
192.168.99.4:8080 -> 192.168.99.6:15280 and should we support
such kind of setups?

	May be you'll need a function in ip_vs_nfct.c that ensures
the packet is in reply direction and its original dest is the
vaddr as you already check. You will need an alternative
function in ip_vs.h when CONFIG_IP_VS_NFCT is not defined.
See ip_vs_conntrack_enabled() for reference. You can not directly
use nf_ functions in ip_vs_core.c

> 01:50:33.158284 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
> seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236082988
> ecr 0,nop,wscale 7], length 0
> 01:50:33.158429 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> val 4198593919 ecr 2236082988,nop,wscale 7], length 0
> 01:50:33.158496 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> seq 886133764, win 0, length 0
> 01:50:34.168530 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
> seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236083999
> ecr 0,nop,wscale 7], length 0
> 01:50:34.168722 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> val 4198594929 ecr 2236082988,nop,wscale 7], length 0
> 01:50:34.168754 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> val 4198594929 ecr 2236082988,nop,wscale 7], length 0
> 01:50:34.168751 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> seq 886133764, win 0, length 0
> 01:50:34.168769 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> seq 886133764, win 0, length 0
> 01:50:36.216624 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> val 4198596977 ecr 2236082988,nop,wscale 7], length 0
> 01:50:36.216626 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
> seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236086047
> ecr 0,nop,wscale 7], length 0
> 01:50:36.216678 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> seq 886133764, win 0, length 0
> 01:50:36.216690 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> val 4198596977 ecr 2236082988,nop,wscale 7], length 0
> 01:50:36.216693 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> seq 886133764, win 0, length 0
> ^C
> 28 packets captured
> 28 packets received by filter
> 0 packets dropped by kernel
> [root@centos9s vagrant]# cat^C
> [root@centos9s vagrant]# cat /proc/net/nf_conntrack | grep 15280
> ipv4     2 tcp      6 7 CLOSE src=192.168.99.5 dst=192.168.99.6
> sport=15280 dport=8080 src=192.168.99.4 dst=192.168.99.6 sport=8080
> dport=15280 [ASSURED] mark=0 secctx=system_u:object_r:unlabeled_t:s0
> zone=0 use=2
> ipv4     2 tcp      6 53 SYN_RECV src=192.168.99.5 dst=192.168.99.4
> sport=15280 dport=8080 src=192.168.99.4 dst=192.168.99.6 sport=8080
> dport=1279 mark=0 secctx=system_u:object_r:unlabeled_t:s0 zone=0 use=2

	dport=1279 ? Not 15280 ? Is it from your test?

Regards

--
Julian Anastasov <ja@ssi.bg>

