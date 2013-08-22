From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Thu, 22 Aug 2013 09:43:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Drunkard Zhang <gongfan193@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>


	Hello,

On Tue, 20 Aug 2013, Drunkard Zhang wrote:

> Need help here, thank you for replying :-)
> 
> I'm setting up a syslog cluster based on IPVS, all UDP datagrams sent
> from firewall with fixed source IP and fixed source port, so
> pseudo-random balancing based on client IP and port won't working. And
> it seems that keepalived is not supporting One-packet scheduling
> option, so I did some hacks on it after keepalived started:
> 
> 1. dump LVS rules with ipvsadm -S -n > rules-vs3;
> 2. add --ops option;
> 3. restore LVS rules with ipvsadm-restore < rules-vs3;
> 4. dump the running LVS rules with ipvsadm -S -n
> 
> So, I got two problems here:
> 
> 1. Dumped rules in step 4 above is not usable anymore, the double-dash
> in --ops lost, so I can't restore rule with this dump anymore. This
> must be a bug.
> 
> 2. The --ops option is not working sometimes you applied the rules,
> and in most of times the --ops just not working. To make it work, just
> 'ipvsadm-restore < rules-vs3' for plenty of times until it's working.
> I haven't find the patterns make it work yet. This is lucky, I can't
> get it work on second host at all.
> 
> The "not working" above means the UDP datagrams from one source IP is
> sticked to one realserver, it doesn't distribute to other realservers
> which --ops designed for.

	Can you try with recent ipvsadm from git:

git clone git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

	I see related commit that will print -o for
the OPS feature:

===
commit 6a03100c189d00e3a8235215392465b5b877ba8f
Author: Krzysztof Gajdemski <songo@debian.org.pl>
Date:   Thu Mar 21 11:40:06 2013 +0100

    ipvsadm: Fix wrong format of -o option in FMT_RULE listing

    'ipvsadm -S' listed one-packet scheduling option in wrong format
    ('ops' instead of '--ops' or '-o') preventing any service with OPS
    feature from restoring using 'ipvsadm -R'.  Now we use '-o' which
    works well with save/restore commands.

    Signed-off-by: Krzysztof Gajdemski <songo@debian.org.pl>
    Signed-off-by: Simon Horman <horms@verge.net.au>
===

	Let me know if you still have any problems with OPS.
Sending to lvs-devel@vger.kernel.org and
lvs-users@linuxvirtualserver.org should be enough for
ipvsadm related discussions.

> So I wondering if there's some CONFIG_* options that ipvs needs, or
> recent development broke the code?

	No kernel options should be related to OPS. I assume
you are not using the SH scheduler. Make sure the OPS mode
is properly applied to the virtual service, check for "ops"
in the configuration:

cat /proc/net/ip_vs

> Do I need to attach kernel config file?

	No

Regards

--
Julian Anastasov <ja@ssi.bg>
