From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: xt_ipvs match does not translate source address for ipvs
Date: Fri, 28 Jun 2013 12:04:18 -0700
Message-ID: <CAK3+h2yMTEUVhDbP9qSj-S0HgLtcK+jmX=J50xO-HvD08mz7QQ@mail.gmail.com>
References: <CAK3+h2ykFzFn3oFbc7Yo3jij_o3xikTmG5QBVZ3qUiOgdwvVMA@mail.gmail.com>
	<alpine.LFD.2.00.1306280900450.1655@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=wDGetIVvAtAaD0cePGxz5SkRsm36hjodM+aGloBTXKY=;
        b=BjXqdklDNOmXd3CLSrblzosE8BJHfcF6qh9mqMeW2/zydgacq13++RACDtN7iPPq99
         c8DwVcgKUybTUQdE/4aP5h6PrUMVDqW0UF6pPGF/H0d2xR1G2MrJLSkM/Njj2yy4Aog0
         cZHZ0W5wMVIDhdrckfqcRH11Qi+FpJ1ebd2p2iftEbrXtsXRwMpFqXsyHsHV8AMpNf2x
         zQdgORxbSZhNbE3uNZ4XKTVlalIwpyYteA4Db6epKXXY5Db4KTUKjAgBBDczGU8AhXiK
         nHb9ZnKG9VnIlb4aBfzC67sY4BPr0BXZ1UbINHtaVR9TLFHKsQ73VoXxnmbepXOuU7T3
         OA2Q==
In-Reply-To: <alpine.LFD.2.00.1306280900450.1655@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Hannes Eder <heder@google.com>

ah, yes, I didn't set  the sysctl conntrack to 1, it works now, thanks
a lot, sorry for the noise

On Thu, Jun 27, 2013 at 11:07 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Thu, 27 Jun 2013, Vincent Li wrote:
>
>> Hi,
>>
>> I am running most recent net-next git tree version and compiled the
>> xt_ipvs match extension for ipvs, here is the info:
>>
>> # uname -a
>> Linux vincent-hp 3.10.0-rc6-ipvs-with-nat #3 SMP Wed Jun 26 21:19:32
>> PDT 2013 i686 GNU/Linux
>>
>> Module                  Size  Used by
>> xt_TRACE                 726  0
>> xt_tcpudp               1895  0
>> iptable_raw             1162  0
>> xt_LOG                 11066  0
>> arptable_filter         1122  0
>> arp_tables              9012  1 arptable_filter
>> iptable_filter          1302  0
>> xt_nat                  1746  2
>> iptable_nat             2646  1
>> nf_conntrack_ipv4      12368  1
>> nf_defrag_ipv4          1181  1 nf_conntrack_ipv4
>> nf_nat_ipv4             3487  1 iptable_nat
>> ip_tables              10235  3 iptable_raw,iptable_filter,iptable_nat
>> nf_nat                 14458  3 xt_nat,iptable_nat,nf_nat_ipv4
>> xt_ipvs                 1620  2
>> x_tables               15304  10
>> xt_TRACE,xt_tcpudp,iptable_raw,xt_LOG,arptable_filter,arp_tables,iptable_filter,xt_nat,ip_tables,xt_ipvs
>> binfmt_misc             5844  1
>> ppdev                   5120  0
>> ip_vs_rr                1643  2
>> ip_vs                 148089  6 xt_ipvs,ip_vs_rr
>> nf_conntrack           77550  5
>> iptable_nat,nf_conntrack_ipv4,nf_nat_ipv4,nf_nat,ip_vs
>> libcrc32c                855  1 ip_vs
>>
>> root@vincent-hp:/usr/src/net-next# iptables -t nat -n -L
>> Chain PREROUTING (policy ACCEPT)
>> target     prot opt source               destination
>>
>> Chain INPUT (policy ACCEPT)
>> target     prot opt source               destination
>>
>> Chain OUTPUT (policy ACCEPT)
>> target     prot opt source               destination
>>
>> Chain POSTROUTING (policy ACCEPT)
>> target     prot opt source               destination
>> SNAT       all  --  0.0.0.0/0            0.0.0.0/0            vaddr
>> 10.1.72.169 vport 80 to:10.2.72.139
>> SNAT       all  --  0.0.0.0/0            0.0.0.0/0            vaddr
>> 10.1.72.169 vport 22 to:10.2.72.139
>>
>> # ipvsadm -L -n
>>
>> IP Virtual Server version 1.2.1 (size=4096)
>> Prot LocalAddress:Port Scheduler Flags
>>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
>> TCP  10.1.72.169:22 rr
>>   -> 10.2.72.99:22                Masq    1      0          0
>> TCP  10.1.72.169:80 rr
>>   -> 10.2.72.9:80                 Masq    1      0          0
>>   -> 10.2.72.99:80                Masq    1      0          0
>>
>> no any filter, mangle, raw iptable rules.
>>
>> the ipvs load balance works fine, but running tcpdump on LVS director
>> and real server shows the client source address is not translated to
>> specified address 10.2.72.139.
>>
>> I used TRACE target in raw filter to trace the packet, I saw the
>> packet went through 'nat' table PREROUTING chain, not POSTROUTING
>> chain.
>>
>> I am using LVS NAT mode. I have seen this issue before with previous
>> kernel 3.6.x release, but not bothered to file report, it hasn't
>> worked for me so I am wondering if I am missing something or there is
>> bug in xt_ipvs match extension, any debugging tips or idea would be
>> appreciated.
>
>         Make sure you have CONFIG_IP_VS_NFCT enabled and
> sysctl var "conntrack" set to 1. IIRC, it is needed for
> xt_ipvs in 2.6.37+. Let me know if you still have problems,
> so that we can track the problem.
>
>> I can post the tcpdump capture or debugging message with TRACE in raw
>> table if needed
>>
>> Thanks
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
