From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Sat, 24 Aug 2013 16:17:01 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com> <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com> <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
 <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com> <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg> <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Drunkard Zhang <gongfan193@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sat, 24 Aug 2013, Drunkard Zhang wrote:

> I'm running x86_64 kernel. I compared kernel config of my two servers,
> a big difference between them is CONFIG_PREEMPT. While CONFIG_PREEMPT
> is disabled, trying plenty times of "ipvsadm -C && ipvsadm -R <
> rules-with-ops" will finally succeed, but with CONFIG_PREEMPT enabled

	There is no "./" in above ipvsadm commands,
I hope you put everything in scripts to make sure
the new ipvsadm binary is used.

> it's too hard to get --ops work. I will test again on my "good" server
> another day to prove my guessing.

	My tests are on 32-bit UP, may be that is why I can
not reproduce it.

> Is there any good debug method for this? Tuning
> /proc/sys/net/ipv4/vs/debug_level didn't gave me much.

echo 20 > /proc/sys/net/ipv4/vs/debug_level

	should show something but don't do it for
60K packets/sec

> I use keepalived to manage the ipvs configuration, but as vrrp
> heartbeat going on and no realserver up/down, it won't interact with
> ipvs, right? So I can temporarily modify ipvs rule via ipvsadm after
> keepalived started, and the modified rules didn't changed as time fly,
> so do the --ops setting.

	Yes, just make sure ops is present after the tests,
in case some daemon removes the flag.

> >         More things to check:
> >
> > - if traffic stops check if some real server is hijacking the
> > traffic from director due to ARP problem in the real server.
> > Or explain how exactly OPS stops to work, do you see other
> > traffic for the VIP coming to director during such problem?
> >
> No possibility, I configured VIP on lo of realserver.
> for IP in $VIP; do
>     ip addr add $IP/32 dev $VIP_NIC brd $IP
> done

	Setting these flags on "lo" is useless but
"all" values should do the job, so ARP problem is
solved.

> sysctl -q -w net.ipv4.conf.lo.arp_ignore=1
> sysctl -q -w net.ipv4.conf.lo.arp_announce=2
> sysctl -q -w net.ipv4.conf.all.arp_ignore=1
> sysctl -q -w net.ipv4.conf.all.arp_announce=2
> 
> > - Build ipvsadm with 'make HAVE_NL=0' to check if Conns=0 problem
> > in --stats output is netlink related. This builds ipvsadm without
> > netlink support but use this binary only to see stats, not
> > for configuration.
> >
> > - show output from 'cat /proc/net/ip_vs_stats_percpu' to see
> > the kernel's stats and rates. Note that these stats are not
> > zeroed while stats in /proc/net/ip_vs_stats are zeroed.
> 
> Always changing.

	Even when OPS does not work?

> vs3 ~ # cat /proc/net/ip_vs_stats_percpu
>        Total Incoming Outgoing         Incoming         Outgoing
> CPU    Conns  Packets  Packets            Bytes            Bytes
>   0 8F11751F 70455AB5        0      10AA672610D                0
>   1 1A780554 1A780554        0        E2AB71BCA                0
>   2        0        0        0                0                0
>   3   BF0E0B   BF0E0B        0         4B7E409C                0
>   4 244BAF54 244BAF54        0       2224071265                0
>   5 2360B25C 2360B25B        0       1715A45DB3                0
>   6        0        0        0                0                0
>   7   E88FEF   E88FEF        0         6ECC3067                0
>   8 1E2477AE 1E2477AE        0       12726CDE2E                0
>   9 10BD4D97 10BD4D97        0        A35650024                0
>   A  BE81916  BE81914        0        6D9FD6CEF                0
>   B 4474D837 4474D836        0       3FCEC43B56                0
>   C        0        0        0                0                0
>   D        0        0        0                0                0
>   E        0        0        0                0                0
>   F        0        0        0                0                0
>   ~ 721BAF1B 534F94AD        0      1B61556B50B                0
> 
>      Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
>        1120F    1120F        0           C1FEB1                0

	So, to summarize for the both cases when OPS
works and when OPS does not work:

- you check after every rule restoring that the ops is
present in kernel rules: cat /proc/net/ip_vs

- in both cases traffic is received on director (no ARP
problem): tcpdump -lnnn -i $INPUT_DEVICE -c 10 $VIP

- cat /proc/net/ip_vs_stats_percpu in both cases shows
that Conns for CPU "~" (Totals) are increasing and "Conns/s"
rate is above 0. Help me to understand the Conns=0 and CPS=0
values in ipvsadm, they are showing 0 in both cases,
right?

- where do you see that OPS is not working? In
ipvsadm -ln --stats/--rate ? Or packets do not
reach real servers? Do you see that rates or stats
for the real servers stop in ipvsadm output?

	May be we can enable debug for short time when
OPS is not working:

# Start debug for 10ms
echo 20 > /proc/sys/net/ipv4/vs/debug_level
usleep 10000
# Stop debug
echo 0 > /proc/sys/net/ipv4/vs/debug_level

	You can show me such debug. The main thing to
understand is where in IPVS the traffic is lost, the
debug will be helpful, it should be no more than one
page per packet. I need debug for one packet, something
that you see is repeated in logs. May be due to the 
destination trash mechanism something is not set properly
after the ipvsadm -C && ipvsadm -R sequence.

Regards

--
Julian Anastasov <ja@ssi.bg>
