From: Drunkard Zhang <gongfan193@gmail.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Mon, 26 Aug 2013 10:07:35 +0800
Message-ID: <CAJiejCTBmSqog3WrfbgD9Cw6e4wXGCyhJX+cKvFbv9Dg=zF_AA@mail.gmail.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
 <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
 <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg> <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com>
 <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg> <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
 <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bd770307d9d8c04e4d039a5
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=oezeN4imdyCRAGHr62X946gep0NsDDPBxflKkcdpucw=;
        b=X9TgDUHdgrxuTjn78PBR5pZbFh1AFQi3qecmeDEXi56c57pjMdqW9jNAqkJz/15Sq0
         ShAT28crTj5QGCTPFHW2QjWwzik8unbgsj2m8WlbFQjLLS3QcIpbJLzsTv70Wvk5RHcW
         KhzqlFa+l+Z3o65k0Nnn7t7E5vATfHeAI2/TFTkPjNqzqO9goKtUHmhvVIJhFVeuQcD4
         qzXot1/+x/sxyrq1OaOo8uq0fyk6Cn3M/UrF1fJEj5FsCChXoLCYZY7SCLK0hG1taOPW
         JtEQJuMPaeO5+89mgQ1akgIJWWb5Gk9NQb3LO6frgGmyloKWulb3JzVKsTReYsHT4ACV
         zhwQ==
In-Reply-To: <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

--047d7bd770307d9d8c04e4d039a5
Content-Type: text/plain; charset=UTF-8

2013/8/24 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Sat, 24 Aug 2013, Drunkard Zhang wrote:
>
>> I'm running x86_64 kernel. I compared kernel config of my two servers,
>> a big difference between them is CONFIG_PREEMPT. While CONFIG_PREEMPT
>> is disabled, trying plenty times of "ipvsadm -C && ipvsadm -R <
>> rules-with-ops" will finally succeed, but with CONFIG_PREEMPT enabled
>
>         There is no "./" in above ipvsadm commands,
> I hope you put everything in scripts to make sure
> the new ipvsadm binary is used.
>
>> it's too hard to get --ops work. I will test again on my "good" server
>> another day to prove my guessing.
>
>         My tests are on 32-bit UP, may be that is why I can
> not reproduce it.
>
>> Is there any good debug method for this? Tuning
>> /proc/sys/net/ipv4/vs/debug_level didn't gave me much.
>
> echo 20 > /proc/sys/net/ipv4/vs/debug_level
>
>         should show something but don't do it for
> 60K packets/sec
>
>> I use keepalived to manage the ipvs configuration, but as vrrp
>> heartbeat going on and no realserver up/down, it won't interact with
>> ipvs, right? So I can temporarily modify ipvs rule via ipvsadm after
>> keepalived started, and the modified rules didn't changed as time fly,
>> so do the --ops setting.
>
>         Yes, just make sure ops is present after the tests,
> in case some daemon removes the flag.
>
>> >         More things to check:
>> >
>> > - if traffic stops check if some real server is hijacking the
>> > traffic from director due to ARP problem in the real server.
>> > Or explain how exactly OPS stops to work, do you see other
>> > traffic for the VIP coming to director during such problem?
>> >
>> No possibility, I configured VIP on lo of realserver.
>> for IP in $VIP; do
>>     ip addr add $IP/32 dev $VIP_NIC brd $IP
>> done
>
>         Setting these flags on "lo" is useless but
> "all" values should do the job, so ARP problem is
> solved.
>
>> sysctl -q -w net.ipv4.conf.lo.arp_ignore=1
>> sysctl -q -w net.ipv4.conf.lo.arp_announce=2
>> sysctl -q -w net.ipv4.conf.all.arp_ignore=1
>> sysctl -q -w net.ipv4.conf.all.arp_announce=2
>>
>> > - Build ipvsadm with 'make HAVE_NL=0' to check if Conns=0 problem
>> > in --stats output is netlink related. This builds ipvsadm without
>> > netlink support but use this binary only to see stats, not
>> > for configuration.
>> >
>> > - show output from 'cat /proc/net/ip_vs_stats_percpu' to see
>> > the kernel's stats and rates. Note that these stats are not
>> > zeroed while stats in /proc/net/ip_vs_stats are zeroed.
>>
>> Always changing.
>
>         Even when OPS does not work?
>
>> vs3 ~ # cat /proc/net/ip_vs_stats_percpu
>>        Total Incoming Outgoing         Incoming         Outgoing
>> CPU    Conns  Packets  Packets            Bytes            Bytes
>>   0 8F11751F 70455AB5        0      10AA672610D                0
>>   1 1A780554 1A780554        0        E2AB71BCA                0
>>   2        0        0        0                0                0
>>   3   BF0E0B   BF0E0B        0         4B7E409C                0
>>   4 244BAF54 244BAF54        0       2224071265                0
>>   5 2360B25C 2360B25B        0       1715A45DB3                0
>>   6        0        0        0                0                0
>>   7   E88FEF   E88FEF        0         6ECC3067                0
>>   8 1E2477AE 1E2477AE        0       12726CDE2E                0
>>   9 10BD4D97 10BD4D97        0        A35650024                0
>>   A  BE81916  BE81914        0        6D9FD6CEF                0
>>   B 4474D837 4474D836        0       3FCEC43B56                0
>>   C        0        0        0                0                0
>>   D        0        0        0                0                0
>>   E        0        0        0                0                0
>>   F        0        0        0                0                0
>>   ~ 721BAF1B 534F94AD        0      1B61556B50B                0
>>
>>      Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
>>        1120F    1120F        0           C1FEB1                0
>
>         So, to summarize for the both cases when OPS
> works and when OPS does not work:
>
> - you check after every rule restoring that the ops is
> present in kernel rules: cat /proc/net/ip_vs

Sure, ops is always there.

> - in both cases traffic is received on director (no ARP
> problem): tcpdump -lnnn -i $INPUT_DEVICE -c 10 $VIP

Also sure.

> - cat /proc/net/ip_vs_stats_percpu in both cases shows
> that Conns for CPU "~" (Totals) are increasing and "Conns/s"
> rate is above 0. Help me to understand the Conns=0 and CPS=0
> values in ipvsadm, they are showing 0 in both cases,
> right?

Badly, Conns is a fixed number and Conns/s is zero.

vs3 ~ # cat /proc/net/ip_vs_stats_percpu
       Total Incoming Outgoing         Incoming         Outgoing
CPU    Conns  Packets  Packets            Bytes            Bytes
  0       12  3C3C98F        0        2CB498261                0
  1        0   54324B        0         4BEFFBB9                0
  2        0     50C2        0           1F37E8                0
  3        0        0        0                0                0
  4        0        0        0                0                0
  5        0    1BC7A        0          1635AF3                0
  6        0   31A7BE        0         1CDC43C7                0
  7        0   2B4E76        0         1BF498BE                0
  8        0    1D418        0           B86A6E                0
  9        0   5B49E8        0         54FD74D5                0
  A        0   75147D        0         410A95C0                0
  B        0        0        0                0                0
  C        0    BD570        0          49118C5                0
  D        0        0        0                0                0
  E        0   211948        0         138B63C5                0
  F        0   626075        0         402A470B                0
  ~       12  5D7664E        0        43FC611F8                0

     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
           0     EF93        0           AE2DD9                0

> - where do you see that OPS is not working? In
> ipvsadm -ln --stats/--rate ? Or packets do not
> reach real servers? Do you see that rates or stats
> for the real servers stop in ipvsadm output?

I'm sure OPS is not working, both from ipvsadm -ln --stats/--rate and
iftop -i eth0 -f "udp port 514" on real server. There's no ingress
traffice at all when InPPS/InBPS from --rate is 0, but OPS is set.

>         May be we can enable debug for short time when
> OPS is not working:
>
> # Start debug for 10ms
> echo 20 > /proc/sys/net/ipv4/vs/debug_level
> usleep 10000
> # Stop debug
> echo 0 > /proc/sys/net/ipv4/vs/debug_level
>
>         You can show me such debug. The main thing to
> understand is where in IPVS the traffic is lost, the
> debug will be helpful, it should be no more than one
> page per packet. I need debug for one packet, something
> that you see is repeated in logs. May be due to the
> destination trash mechanism something is not set properly
> after the ipvsadm -C && ipvsadm -R sequence.

sleep 1 does not help with `ipvsadm -C && sleep 1 && ipvsadm -R <
rules-with-ops`.

Debug log is attached. bad-20130826-init.gz is produced by:
./ipvsadm -C
# Clear previous log
> /var/log/kern.log
sleep 3
# Start debug
echo 20 > /proc/sys/net/ipv4/vs/debug_level
./ipvsadm -R < /etc/keepalived/rules-with-ops
usleep 10000
# Stop debug
echo 0 > /proc/sys/net/ipv4/vs/debug_level

bad-20130826-running.gz and good-20130825-running.gz is produced by:
# Start debug for 10ms
echo 20 > /proc/sys/net/ipv4/vs/debug_level
usleep 10000
# Stop debug
echo 0 > /proc/sys/net/ipv4/vs/debug_level

good-20130825-running.gz is captured when OPS working. I noticed that
after long time of running (ops is configured but not working), like
24 hours, restore the rules again, it may works sometimes. But with
newly started kernel, it's just too hard to get ops working.

--047d7bd770307d9d8c04e4d039a5
Content-Type: application/x-gzip; name="bad-20130826-init.gz"
Content-Disposition: attachment; filename="bad-20130826-init.gz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hkt1jroj0

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
--047d7bd770307d9d8c04e4d039a5
Content-Type: application/x-gzip; name="bad-20130826-running.gz"
Content-Disposition: attachment; filename="bad-20130826-running.gz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hkt1jwuc1

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
ofRCged/BSC5WOD7/wAsky//A4CZyarucAMA
--047d7bd770307d9d8c04e4d039a5
Content-Type: application/x-gzip; name="good-20130825-running.gz"
Content-Disposition: attachment; filename="good-20130825-running.gz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hkt1k4jo2

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
--047d7bd770307d9d8c04e4d039a5--
