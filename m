Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 543A422A7E0;
	Wed, 21 May 2025 02:01:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747792899; cv=none; b=GE6RS7dfvJPWNCwxRlVnkem3GRs4uw8ZRrEAiVwn6cc75WJmAltbguxBO68HiAViZhztD4ufD79cGMTzfvttwNLRN+wyfSn4C+q/gSgaPGiuGWSIt7Z9kyD30w5LDYVHSw+7QopvttjJKInHuNlKrckXxIaEerg2Hwa5fLaJsLo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747792899; c=relaxed/simple;
	bh=Rm+7i+9QHR7BreAT2i7Vr0/1STQv1PuRFH1PXC9q8JU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=t7rIdKmwgQjPboWRwcJZhgBs0rtlueMUiU+1Xyo4lJoP0pVcocwXIknq+PKbo4pHdSaOv0/lU4SfsSEKEhmpSzW69JGvqAtylhI0Nj8Rvk1R0om+SO/EQjVCV4ouHfgriQPvkvT5skPWOVWk6VHk/TrIfIBM03OjKIoCm8iUxfo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=BehnGr8Y; arc=none smtp.client-ip=209.85.208.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BehnGr8Y"
Received: by mail-ed1-f54.google.com with SMTP id 4fb4d7f45d1cf-601956fa3beso6364380a12.0;
        Tue, 20 May 2025 19:01:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1747792895; x=1748397695; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=nh2drR1IAA1fY2m1PRAVMWMgdf9oKuSF4EgBnfE0Tiw=;
        b=BehnGr8YNDnEG7BDcFpy3XLJuvSJt4IHqgwgGS7iEVBMoa+9ZEPdy6Kmr19DhPmYT3
         Cqc/4QjLrQxIfnZL6V8AO43cyh++8yLqW0dv/Ovot2avQsNfEsLhGCP4hFyActgv8Xtk
         Vo323hYM/09xc4i4SEYMrstBjkvWjsj8Ldb6ch4iyZhKu4xSPbwxOBLDuseDLhKj7/V/
         bD8ud7WdjcLXX9GGd9A7ZEMY5JfD41EKBUIbA5mV6Ea+U8qKpaGqngfLO7IdiCmaXxK0
         VaCmup1sjX1P4+U54CN0RFtzrgjU7FPIUjIYDEyP6/t0obprR4ZPmQWUn7BupIRtd0vR
         7JUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747792895; x=1748397695;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=nh2drR1IAA1fY2m1PRAVMWMgdf9oKuSF4EgBnfE0Tiw=;
        b=fbQ3H5G3vbYQSmgX4Aj1EibA7brzd2B3okCJX6Rs6r9HFE1JfczzvXtIj9os6FOBEQ
         sT5PdEvHoNt2f+96Kfnf9RaJjpwvo7huAfFWN33ZFqdV3l2TCyfdDbNH7BlO+KKYWCNc
         lphfHaygqzto4IAgdlXfOjAcC7Uqih6YYOt3eeRmfiIRadGhO3ypNtCEMLbIhiHWWhzY
         1RNSUUn3sr+PdRTSKVufFh1KWZrMdpi2H8nlTQSD3V4jNcs3bZyFnx/WH07zYjAtwpd1
         oJ/+dWGsB5FHb4SSqQEDGGFdHjGPUdayjuBOSCt0lEUkBjcMZq/dyD4A9eXRbTOvPuFF
         OR8g==
X-Forwarded-Encrypted: i=1; AJvYcCU02AvX5K9E+dJJI5U2rMdAa9Cjr7+z87CqVvKF5XqbOYjQDrx4LBG9v9hHYa7Ggl6lcATWcZ9wmgI=@vger.kernel.org, AJvYcCW+L5pniZD2gteO148XYAsKJFzH9DGVDhk55/+90qE/Z1KLSydFMhtmjwVpTPZ46R/azclPhU3M@vger.kernel.org
X-Gm-Message-State: AOJu0YzSbPfQwB8WOzzlp+vfVL7uCGNSHA6Js8TPu8YnwtasOEw6YfAx
	Oy8XrkHXnEVDYP8sEvxgDmM+M1PvXA6A/MERVGCwXjTiwvwR85/K/wy7VdJEAmOj9rICijv43ox
	+FImIfpHWCoMBm0i7d7T4/N2+O6pqh5bS/oPHLfo=
X-Gm-Gg: ASbGnctfH/59GobyV/oAYYEOcHkaqJ3hNoG7U0nNLUDfKao8P1ttwKzQKt/vJrU+XXf
	Rfi2LhAqacry2kPrB5Oe0t2TId+4XiL6U+9AW4J6M2Q80QI+PMY4+VsdDU13yhIIRbZxWBXSJqL
	lu5uoxx7WqTrTQOTLDbT4G77DGzgbPqnWXKXc=
X-Google-Smtp-Source: AGHT+IHpha3vS72+ZD3NRTXQRRz19n3l9MfaTJ4hy05UYQa/NV52iIDmJiZ3HKC5bbqIvDjZnnga4t7rJLFTjD480jA=
X-Received: by 2002:a17:906:730a:b0:ad2:313f:f550 with SMTP id
 a640c23a62f3a-ad52d4cc5f9mr1775650066b.29.1747792895323; Tue, 20 May 2025
 19:01:35 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20250519103203.17255-1-djduanjiong@gmail.com> <aef5ec1d-c62f-9a1c-c6f3-c3e275494234@ssi.bg>
 <CALttK1Sn=D4x81NpEq1ELHoXnEaiMboYBzYeOUX8qKHzDDxk0A@mail.gmail.com> <df6af9cc-35ff-5c3e-3e67-ed2f93a17691@ssi.bg>
In-Reply-To: <df6af9cc-35ff-5c3e-3e67-ed2f93a17691@ssi.bg>
From: Duan Jiong <djduanjiong@gmail.com>
Date: Wed, 21 May 2025 10:01:23 +0800
X-Gm-Features: AX0GCFt--ddANxze57JN4YLoEWaIOR9BLvDnyvMGTanR9zz7wU-qDSdtGaORDSE
Message-ID: <CALttK1SwmRmZC1A0pcT3n-U7tY=0DBqj3j=SSJ9kVYZ6jzGDbA@mail.gmail.com>
Subject: Re: [PATCH] ipvs: skip ipvs snat processing when packet dst is not vip
To: Julian Anastasov <ja@ssi.bg>
Cc: pablo@netfilter.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, May 20, 2025 at 9:28=E2=80=AFPM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Tue, 20 May 2025, Duan Jiong wrote:
>
> > 1.  setup environment
> >
> > [root@centos9s vagrant]# cat setup.sh
> > #!/bin/bash
> >
> > ip netns add server
> > ip link add svrh type veth peer name svr
> > ip link set svr netns server
> > ip link set svrh up
> > ip link set dev svrh address ee:ee:ee:ee:ee:ee
> > ip netns exec server ip link set svr up
> > ip netns exec server ip addr add 192.168.99.4/32 dev svr
> > ip netns exec server ip route add 169.254.1.1 dev svr scope link
> > ip netns exec server ip route add default via 169.254.1.1 dev svr
> > ip netns exec server ip neigh add 169.254.1.1 lladdr ee:ee:ee:ee:ee:ee
> > dev svr nud permanent
> > ip route add 192.168.99.4/32 dev svrh
> >
> > ip netns add client
> > ip link add clih type veth peer name cli
> > ip link set cli netns client
> > ip link set clih up
> > ip link set dev clih address ee:ee:ee:ee:ee:ee
> > ip netns exec client ip link set cli up
> > ip netns exec client ip addr add 192.168.99.5/32 dev cli
> > ip netns exec client ip route add 169.254.1.1 dev cli scope link
> > ip netns exec client ip route add default via 169.254.1.1 dev cli
> > ip netns exec client ip neigh add 169.254.1.1 lladdr ee:ee:ee:ee:ee:ee
> > dev cli nud permanent
> > ip route add 192.168.99.5/32 dev clih
> >
> > ip addr add 192.168.99.6/32 dev lo
> > ipvsadm -A -t 192.168.99.6:8080 -s rr
> > ipvsadm -a -t 192.168.99.6:8080 -r 192.168.99.4:8080 -m
> >
> > echo 1 > /proc/sys/net/ipv4/ip_forward
> > echo 1 >  /proc/sys/net/ipv4/vs/conntrack
> > iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE
> >
> > 2. start server
> > ip netns exec server python -m http.server 8080
> >
> > 3. curl vip
> > ip netns exec client curl --local-port 15280 http://192.168.99.6:8080
> >
> > 4. curl rs
> > ip netns exec client curl --local-port 15280 http://192.168.99.4:8080
> >
> > Here are the ct rules for executing curl and the tcpdump capture.
> >
> > [root@centos9s vagrant]# tcpdump -s0 -nn -i clih
> > dropped privs to tcpdump
> > tcpdump: verbose output suppressed, use -v[v]... for full protocol deco=
de
> > listening on clih, link-type EN10MB (Ethernet), snapshot length 262144 =
bytes
> > 01:50:14.328558 IP6 fe80::fc0e:fff:fef8:7c05 > ff02::2: ICMP6, router
> > solicitation, length 16
>
>         Client correctly connects to VIP:
>
> > 01:50:28.430769 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [S],
> > seq 614710449, win 64240, options [mss 1460,sackOK,TS val 2654895687
> > ecr 0,nop,wscale 7], length 0
> > 01:50:28.431026 ARP, Request who-has 192.168.99.5 tell 192.168.99.6, le=
ngth 28
> > 01:50:28.431034 ARP, Reply 192.168.99.5 is-at fe:0e:0f:f8:7c:05, length=
 28
> > 01:50:28.431035 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> > seq 3593264529, ack 614710450, win 65160, options [mss 1460,sackOK,TS
> > val 4198589191 ecr 2654895687,nop,wscale 7], length 0
> > 01:50:28.431048 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
> > ack 1, win 502, options [nop,nop,TS val 2654895687 ecr 4198589191],
> > length 0
> > 01:50:28.431683 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [P.],
> > seq 1:82, ack 1, win 502, options [nop,nop,TS val 2654895688 ecr
> > 4198589191], length 81: HTTP: GET / HTTP/1.1
> > 01:50:28.431709 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [.],
> > ack 82, win 509, options [nop,nop,TS val 4198589192 ecr 2654895688],
> > length 0
> > 01:50:28.434072 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [P.],
> > seq 1:157, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
> > 2654895688], length 156: HTTP: HTTP/1.0 200 OK
> > 01:50:28.434083 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
> > ack 157, win 501, options [nop,nop,TS val 2654895690 ecr 4198589194],
> > length 0
> > 01:50:28.434166 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [P.],
> > seq 157:1195, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
> > 2654895690], length 1038: HTTP
> > 01:50:28.434171 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [.],
> > ack 1195, win 501, options [nop,nop,TS val 2654895690 ecr 4198589194],
> > length 0
> > 01:50:28.434221 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [F.],
> > seq 1195, ack 82, win 509, options [nop,nop,TS val 4198589194 ecr
> > 2654895690], length 0
> > 01:50:28.434669 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [F.],
> > seq 82, ack 1196, win 501, options [nop,nop,TS val 2654895691 ecr
> > 4198589194], length 0
> > 01:50:28.434712 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [.],
> > ack 83, win 509, options [nop,nop,TS val 4198589195 ecr 2654895691],
> > length 0
>
>         But the following packet is different from your
> initial posting. Why client connects directly to the real server?

when there is a problem accessing the vip, the first thing users may consid=
er
is to check whether the back-end service is normal or not

> Is it allowed to have two conntracks with equal reply tuple
> 192.168.99.4:8080 -> 192.168.99.6:15280 and should we support
> such kind of setups?

No, I don't think this needs to be supported, the tuple in the reply
direction should be different, it's just that here ipvs mistakenly did snat

>
>         May be you'll need a function in ip_vs_nfct.c that ensures
> the packet is in reply direction and its original dest is the
> vaddr as you already check. You will need an alternative
> function in ip_vs.h when CONFIG_IP_VS_NFCT is not defined.
> See ip_vs_conntrack_enabled() for reference. You can not directly
> use nf_ functions in ip_vs_core.c
>
> > 01:50:33.158284 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
> > seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236082988
> > ecr 0,nop,wscale 7], length 0
> > 01:50:33.158429 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> > seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> > val 4198593919 ecr 2236082988,nop,wscale 7], length 0
> > 01:50:33.158496 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> > seq 886133764, win 0, length 0
> > 01:50:34.168530 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
> > seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236083999
> > ecr 0,nop,wscale 7], length 0
> > 01:50:34.168722 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> > seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> > val 4198594929 ecr 2236082988,nop,wscale 7], length 0
> > 01:50:34.168754 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> > seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> > val 4198594929 ecr 2236082988,nop,wscale 7], length 0
> > 01:50:34.168751 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> > seq 886133764, win 0, length 0
> > 01:50:34.168769 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> > seq 886133764, win 0, length 0
> > 01:50:36.216624 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> > seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> > val 4198596977 ecr 2236082988,nop,wscale 7], length 0
> > 01:50:36.216626 IP 192.168.99.5.15280 > 192.168.99.4.8080: Flags [S],
> > seq 886133763, win 64240, options [mss 1460,sackOK,TS val 2236086047
> > ecr 0,nop,wscale 7], length 0
> > 01:50:36.216678 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> > seq 886133764, win 0, length 0
> > 01:50:36.216690 IP 192.168.99.6.8080 > 192.168.99.5.15280: Flags [S.],
> > seq 2329127612, ack 886133764, win 65160, options [mss 1460,sackOK,TS
> > val 4198596977 ecr 2236082988,nop,wscale 7], length 0
> > 01:50:36.216693 IP 192.168.99.5.15280 > 192.168.99.6.8080: Flags [R],
> > seq 886133764, win 0, length 0
> > ^C
> > 28 packets captured
> > 28 packets received by filter
> > 0 packets dropped by kernel
> > [root@centos9s vagrant]# cat^C
> > [root@centos9s vagrant]# cat /proc/net/nf_conntrack | grep 15280
> > ipv4     2 tcp      6 7 CLOSE src=3D192.168.99.5 dst=3D192.168.99.6
> > sport=3D15280 dport=3D8080 src=3D192.168.99.4 dst=3D192.168.99.6 sport=
=3D8080
> > dport=3D15280 [ASSURED] mark=3D0 secctx=3Dsystem_u:object_r:unlabeled_t=
:s0
> > zone=3D0 use=3D2
> > ipv4     2 tcp      6 53 SYN_RECV src=3D192.168.99.5 dst=3D192.168.99.4
> > sport=3D15280 dport=3D8080 src=3D192.168.99.4 dst=3D192.168.99.6 sport=
=3D8080
> > dport=3D1279 mark=3D0 secctx=3Dsystem_u:object_r:unlabeled_t:s0 zone=3D=
0 use=3D2
>
>         dport=3D1279 ? Not 15280 ? Is it from your test?

Yes=EF=BC=8C It's because I added the iptables rule earlier, if I don't add
this the source port will remain at 15280, and
then the syn packet will be dropped in the __nf_conntrack_confirm function.

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
