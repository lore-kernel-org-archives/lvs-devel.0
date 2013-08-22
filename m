From: Drunkard Zhang <gongfan193@gmail.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Thu, 22 Aug 2013 18:58:33 +0800
Message-ID: <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
 <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=BoDwwzZDIBDAxcSC9dmaYPmtHzFNQrr1t0+8+7kOuzw=;
        b=zKCPSoownCt5rMA1I3U8ZR6YplrrNtptAeOzCbfIYclLNeINWHsZhRTBzABY0jYlbR
         n50Z19632wirk8q0RElKkO6VrrzS8ZTgvekY+B1R+5TlL3UxMTG36Dvd1rDYQkz2wS3H
         qWAJPYJFdGxkVIe+Ta4FuO5Sw8s9o1MMIWnUUyhgG2WOM5GXyWZVeOT05R+OgO2BebUH
         0Sh93ijdjiHaEFyYZ05NBRpsqpSOB20BblH+KcQr46NWpBtA/vsYpQZi4/0gMm8/3w1V
         GkIFWqlcnxc7urW96MZ0RTO2Vp9jvpF/vL7MJw7tu7Z+ltNpji6o2jfKZZQraoUqerli
         QyeA==
In-Reply-To: <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

2013/8/22 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Tue, 20 Aug 2013, Drunkard Zhang wrote:
>
>> Need help here, thank you for replying :-)
>>
>> I'm setting up a syslog cluster based on IPVS, all UDP datagrams sent
>> from firewall with fixed source IP and fixed source port, so
>> pseudo-random balancing based on client IP and port won't working. And
>> it seems that keepalived is not supporting One-packet scheduling
>> option, so I did some hacks on it after keepalived started:
>>
>> 1. dump LVS rules with ipvsadm -S -n > rules-vs3;
>> 2. add --ops option;
>> 3. restore LVS rules with ipvsadm-restore < rules-vs3;
>> 4. dump the running LVS rules with ipvsadm -S -n
>>
>> So, I got two problems here:
>>
>> 1. Dumped rules in step 4 above is not usable anymore, the double-dash
>> in --ops lost, so I can't restore rule with this dump anymore. This
>> must be a bug.
>>
>> 2. The --ops option is not working sometimes you applied the rules,
>> and in most of times the --ops just not working. To make it work, just
>> 'ipvsadm-restore < rules-vs3' for plenty of times until it's working.
>> I haven't find the patterns make it work yet. This is lucky, I can't
>> get it work on second host at all.
>>
>> The "not working" above means the UDP datagrams from one source IP is
>> sticked to one realserver, it doesn't distribute to other realservers
>> which --ops designed for.
>
>         Can you try with recent ipvsadm from git:
>
> git clone git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git
>
>         I see related commit that will print -o for
> the OPS feature:
>
> ===
> commit 6a03100c189d00e3a8235215392465b5b877ba8f
> Author: Krzysztof Gajdemski <songo@debian.org.pl>
> Date:   Thu Mar 21 11:40:06 2013 +0100
>
>     ipvsadm: Fix wrong format of -o option in FMT_RULE listing
>
>     'ipvsadm -S' listed one-packet scheduling option in wrong format
>     ('ops' instead of '--ops' or '-o') preventing any service with OPS
>     feature from restoring using 'ipvsadm -R'.  Now we use '-o' which
>     works well with save/restore commands.
>
>     Signed-off-by: Krzysztof Gajdemski <songo@debian.org.pl>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> ===
>
>         Let me know if you still have any problems with OPS.
> Sending to lvs-devel@vger.kernel.org and
> lvs-users@linuxvirtualserver.org should be enough for
> ipvsadm related discussions.

Thanks, this resolved my first problem :D

>> So I wondering if there's some CONFIG_* options that ipvs needs, or
>> recent development broke the code?
>
>         No kernel options should be related to OPS. I assume
> you are not using the SH scheduler. Make sure the OPS mode
> is properly applied to the virtual service, check for "ops"
> in the configuration:
>
> cat /proc/net/ip_vs

Still no lucky here, ops is set in running config, but it's not like
that in real world.

vs3 ~ # cat /proc/net/ip_vs
IP Virtual Server version 1.2.1 (size=1024)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port Forward Weight ActiveConn InActConn
UDP  96A46478:0202 wrr ops
  -> 96A46459:0202      Route   0      0          0
  -> 96A46458:0202      Route   0      0          0
  -> 96A46457:0202      Route   0      0          0
  -> 96A46456:0202      Route   0      0          0
  -> 96A46455:0202      Route   0      0          0
  -> 96A46454:0202      Route   0      0          0
  -> 96A46453:0202      Route   0      0          0
  -> 96A46452:0202      Route   0      0          0
  -> 96A46451:0202      Route   0      0          0
  -> 96A46450:0202      Route   25     0          1
  -> 96A4644F:0202      Route   25     0          1
  -> 96A4644E:0202      Route   25     0          1
  -> 96A4644D:0202      Route   30     0          2
  -> 96A4644C:0202      Route   20     0          1
  -> 96A4644B:0202      Route   20     0          1
  -> 96A4644A:0202      Route   25     0          1
  -> 96A46449:0202      Route   20     0          1
  -> 96A46448:0202      Route   25     0          1
  -> 96A46447:0202      Route   20     0          1
  -> 96A46446:0202      Route   20     0          1
  -> 96A46445:0202      Route   20     0          1
  -> 96A46444:0202      Route   25     0          1
  -> 96A46443:0202      Route   15     0          1
  -> 96A46442:0202      Route   20     0          1
  -> 96A46441:0202      Route   20     0          1

And the traffic routed to each realserver didn't following weight I
set, it's routed pretty much one to one. I got 17 udp sources sending
to 16 different realservers, the others are bonding to another VIP.

Prot LocalAddress:Port                 CPS    InPPS   OutPPS    InBPS   OutBPS
  -> RemoteAddress:Port
UDP  x.x.x.120:514                 0    67622        0 12339373        0
  -> x.x.x.65:514                  0       29        0     2895        0
  -> x.x.x.66:514                  0      225        0    21850        0
  -> x.x.x.67:514                  0     4003        0   586117        0
  -> x.x.x.68:514                  0     5049        0   781526        0
  -> x.x.x.69:514                  0      160        0    16163        0
  -> x.x.x.70:514                  0     6091        0   914365        0
  -> x.x.x.71:514                  0      757        0    74428        0
  -> x.x.x.72:514                  0     4716        0   736039        0
  -> x.x.x.73:514                  0     4167        0   663728        0
  -> x.x.x.74:514                  0     3800        0   571342        0
  -> x.x.x.75:514                  0      192        0    19467        0
  -> x.x.x.76:514                  0    11309        0  1889147        0
  -> x.x.x.77:514                  0     3052        0   309840        0
  -> x.x.x.78:514                  0     8336        0  2004194        0
  -> x.x.x.79:514                  0     7333        0  1747346        0
  -> x.x.x.80:514                  0     8403        0  2000929        0
  -> x.x.x.81:514                  0        0        0        0        0
  -> x.x.x.82:514                  0        0        0        0        0
  -> x.x.x.83:514                  0        0        0        0        0
  -> x.x.x.84:514                  0        0        0        0        0
  -> x.x.x.85:514                  0        0        0        0        0
  -> x.x.x.86:514                  0        0        0        0        0
  -> x.x.x.87:514                  0        0        0        0        0
  -> x.x.x.88:514                  0        0        0        0        0
  -> x.x.x.89:514                  0        0        0        0        0
