From: Drunkard Zhang <gongfan193@gmail.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Sat, 24 Aug 2013 19:14:24 +0800
Message-ID: <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
 <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
 <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg> <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com>
 <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=IqTw7vNlOa6vMuzXdbDxW5msB9z7ZGyLa7RkDBYnSrw=;
        b=eTRp48lKJBfhpqkx0/HBP66W8yxOkeSc1v/WfEUdRBWRxzUrICfZFoJP9x4hIz6PLJ
         v7j5+AkivrtSTjWBJyQANOdvh/nBYlE999F9kC8mgGz5+CcsTE3KStcJphkf8TTfW5lf
         Sp2uFZVZ1QfK/79pySRVfrFw8li+2peVcBqnvX3q9u1g/W7AbagXlgQtqNaW9d/kuIto
         ocgCHP4P4nDlvyGto6M/Ti8BpGuEkujkUi+aC30SnJQ9+rtYwbEqRXSNRQPGr4lPMIPG
         5BLGWK+arwPtcYZb7rUTKyP/mgTe2oPqUKGhp1gO6NanOR6Bc9ui1F7IyV8uZDYVZF3e
         JTMg==
In-Reply-To: <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

2013/8/23 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Fri, 23 Aug 2013, Drunkard Zhang wrote:
>
>> 2013/8/22 Julian Anastasov <ja@ssi.bg>:
>> >
>> > for a very short period, they live up to 1 jiffie, eg. 10ms.
>> > Also, WRR should be reliable for OPS while other
>> > schedulers (eg. *LC) are not suitable.
>>
>> I noticed this too. While ops working, the InActConn is always
>> changing too, if it's fixed, the ops is not working.
>
>         All traffic to director stops?

No,ingress traffic is always on going.

>> >         Do you see the same problem with ipvsadm -Ln --stats ?
>> > ipvsadm -Z may be needed to zero the stats after restoring all
>> > rules. "Conns" counter in stats should be according to WRR
>> > weights, it shows the scheduler decisions.
>>
>> After every restore, the stats also zeroed, right? While, ops still not working.
>
>         Yes:
>
> 1. Configure/Restore rules
> 2. Zero stats: ./ipvsadm -Z
> 3. sleep 5
> 4. ./ipvsadm -ln --stats
>
>> vs3 ~/pkgs # ./ipvsadm -Z
>> vs3 ~/pkgs # ./ipvsadm -ln --stats -u [snipped]
>> Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
>>   -> RemoteAddress:Port
>> UDP  x.x.x.120:514                 0 12497040        0    2572M        0
>>   -> x.x.x.65:514                  0     3975        0   394171        0
>
>         It is really strange to have Conns=0 in stats.
> I just tested OPS on 32-bit x86 (virtualbox) with plain
> 3.10 kernel and there is no problem with CPS, Conns, etc,
> WRR is scheduling according to weights. Do you have a
> daemon that changes weights dynamically?

I'm running x86_64 kernel. I compared kernel config of my two servers,
a big difference between them is CONFIG_PREEMPT. While CONFIG_PREEMPT
is disabled, trying plenty times of "ipvsadm -C && ipvsadm -R <
rules-with-ops" will finally succeed, but with CONFIG_PREEMPT enabled
it's too hard to get --ops work. I will test again on my "good" server
another day to prove my guessing.

Is there any good debug method for this? Tuning
/proc/sys/net/ipv4/vs/debug_level didn't gave me much.

I use keepalived to manage the ipvs configuration, but as vrrp
heartbeat going on and no realserver up/down, it won't interact with
ipvs, right? So I can temporarily modify ipvs rule via ipvsadm after
keepalived started, and the modified rules didn't changed as time fly,
so do the --ops setting.

>         More things to check:
>
> - if traffic stops check if some real server is hijacking the
> traffic from director due to ARP problem in the real server.
> Or explain how exactly OPS stops to work, do you see other
> traffic for the VIP coming to director during such problem?
>
No possibility, I configured VIP on lo of realserver.
for IP in $VIP; do
    ip addr add $IP/32 dev $VIP_NIC brd $IP
done
sysctl -q -w net.ipv4.conf.lo.arp_ignore=1
sysctl -q -w net.ipv4.conf.lo.arp_announce=2
sysctl -q -w net.ipv4.conf.all.arp_ignore=1
sysctl -q -w net.ipv4.conf.all.arp_announce=2

> - Build ipvsadm with 'make HAVE_NL=0' to check if Conns=0 problem
> in --stats output is netlink related. This builds ipvsadm without
> netlink support but use this binary only to see stats, not
> for configuration.
>
> - show output from 'cat /proc/net/ip_vs_stats_percpu' to see
> the kernel's stats and rates. Note that these stats are not
> zeroed while stats in /proc/net/ip_vs_stats are zeroed.

Always changing.

vs3 ~ # cat /proc/net/ip_vs_stats_percpu
       Total Incoming Outgoing         Incoming         Outgoing
CPU    Conns  Packets  Packets            Bytes            Bytes
  0 8F11751F 70455AB5        0      10AA672610D                0
  1 1A780554 1A780554        0        E2AB71BCA                0
  2        0        0        0                0                0
  3   BF0E0B   BF0E0B        0         4B7E409C                0
  4 244BAF54 244BAF54        0       2224071265                0
  5 2360B25C 2360B25B        0       1715A45DB3                0
  6        0        0        0                0                0
  7   E88FEF   E88FEF        0         6ECC3067                0
  8 1E2477AE 1E2477AE        0       12726CDE2E                0
  9 10BD4D97 10BD4D97        0        A35650024                0
  A  BE81916  BE81914        0        6D9FD6CEF                0
  B 4474D837 4474D836        0       3FCEC43B56                0
  C        0        0        0                0                0
  D        0        0        0                0                0
  E        0        0        0                0                0
  F        0        0        0                0                0
  ~ 721BAF1B 534F94AD        0      1B61556B50B                0

     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
       1120F    1120F        0           C1FEB1                0
