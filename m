From: Drunkard Zhang <gongfan193@gmail.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Fri, 23 Aug 2013 07:24:07 +0800
Message-ID: <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
 <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
 <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=1SUpkWHv3EaWCn96HIs/hnoxNmpPNNt0rUIR5/d0Zqo=;
        b=UlidwUxE39iwe1EmoxnVBXRw1lPQQy0vi+b6PVEqo8UE3HG/Uxox3kM7adxy/QrcXJ
         ZhgC+1glPwrNA9oN0RtrHiPZ3IPCyjDYYhi9S7gBYNWymPagzBDYYo9oneOth6jFHulC
         mcsWPAYL/tI59RZ7iHvwdx0srW/Q5H66475zmLNhmifbIXZQhgDbgsaS8KNa7etZxm5C
         RKmWcrLWBgYzD2FmdWJmCeogEhBdrlK4aM01kH7KQuN+KCzUc/8WAV93zbJklZKelsf1
         0tlxPf90mQXT2FM05mNjI8PXdVCn9sxnq07EgHMuwT69TNmDsaDwSBRODZvjkVJqIL/9
         tB6g==
In-Reply-To: <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

2013/8/22 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Thu, 22 Aug 2013, Drunkard Zhang wrote:
>
>> 2013/8/22 Julian Anastasov <ja@ssi.bg>:
>> >
>> >         No kernel options should be related to OPS. I assume
>> > you are not using the SH scheduler. Make sure the OPS mode
>> > is properly applied to the virtual service, check for "ops"
>> > in the configuration:
>> >
>> > cat /proc/net/ip_vs
>>
>> Still no lucky here, ops is set in running config, but it's not like
>> that in real world.
>>
>> vs3 ~ # cat /proc/net/ip_vs
>> IP Virtual Server version 1.2.1 (size=1024)
>> Prot LocalAddress:Port Scheduler Flags
>>   -> RemoteAddress:Port Forward Weight ActiveConn InActConn
>> UDP  96A46478:0202 wrr ops
>
>>   -> 96A46450:0202      Route   25     0          1
>
>         The OPS connections are accounted in InActConn
> for a very short period, they live up to 1 jiffie, eg. 10ms.
> Also, WRR should be reliable for OPS while other
> schedulers (eg. *LC) are not suitable.

I noticed this too. While ops working, the InActConn is always
changing too, if it's fixed, the ops is not working.

>> And the traffic routed to each realserver didn't following weight I
>> set, it's routed pretty much one to one. I got 17 udp sources sending
>> to 16 different realservers, the others are bonding to another VIP.
>>
>> Prot LocalAddress:Port                 CPS    InPPS   OutPPS    InBPS   OutBPS
>>   -> RemoteAddress:Port
>> UDP  x.x.x.120:514                 0    67622        0 12339373        0
>>   -> x.x.x.65:514                  0       29        0     2895        0
>>   -> x.x.x.66:514                  0      225        0    21850        0
>
>         Do you see the same problem with ipvsadm -Ln --stats ?
> ipvsadm -Z may be needed to zero the stats after restoring all
> rules. "Conns" counter in stats should be according to WRR
> weights, it shows the scheduler decisions.

After every restore, the stats also zeroed, right? While, ops still not working.

vs3 ~/pkgs # ./ipvsadm -Z
vs3 ~/pkgs # ./ipvsadm -ln --stats -u [snipped]
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
UDP  x.x.x.120:514                 0 12497040        0    2572M        0
  -> x.x.x.65:514                  0     3975        0   394171        0
  -> x.x.x.66:514                  0    48466        0  4835716        0
  -> x.x.x.67:514                  0   407051        0 58479621        0
  -> x.x.x.68:514                  0   561120        0 85289892        0
  -> x.x.x.69:514                  0    30958        0  3120506        0
  -> x.x.x.70:514                  0   645475        0  100552K        0
  -> x.x.x.71:514                  0   147228        0 14560649        0
  -> x.x.x.72:514                  0   535693        0 84069390        0
  -> x.x.x.73:514                  0   564787        0 88165140        0
  -> x.x.x.74:514                  0   346734        0 53256088        0
  -> x.x.x.75:514                  0    47232        0  4801578        0
  -> x.x.x.76:514                  0  1175288        0  192699K        0
  -> x.x.x.77:514                  0   254915        0 25939720        0
  -> x.x.x.78:514                  0  2701531        0  652417K        0
  -> x.x.x.79:514                  0  2426686        0  573897K        0
  -> x.x.x.80:514                  0  2599901        0  629793K        0
  -> x.x.x.81:514                  0        0        0        0        0
  -> x.x.x.82:514                  0        0        0        0        0
  -> x.x.x.83:514                  0        0        0        0        0
  -> x.x.x.84:514                  0        0        0        0        0
  -> x.x.x.85:514                  0        0        0        0        0
  -> x.x.x.86:514                  0        0        0        0        0
  -> x.x.x.87:514                  0        0        0        0        0
  -> x.x.x.88:514                  0        0        0        0        0
  -> x.x.x.89:514                  0        0        0        0        0

>         In your rates listing CPS 0 is confusing, even for OPS.
> Is it from the new ipvsadm?

Yes, latest git version. When CPS is changing, the ops works, or it's not.
