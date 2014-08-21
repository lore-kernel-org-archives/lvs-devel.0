From: Chris J Arges <chris.j.arges@canonical.com>
Subject: ip_vs: bug in ip_vs_out when CONFIG_IP_VS_IPV6 is enabled
Date: Thu, 21 Aug 2014 14:44:36 -0500
Message-ID: <53F64C24.1080309@canonical.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Julian Anastasov <ja@ssi.bg>

A bug was reported against our kernel, which looks to be an upstream
issue after some testing (as of 3.17-rc1).

In short, it seems that using ip_vs with something like dnsmasq-tftp to
send data will cause the transfer to stop at some point where the read
will error giving EPERM. It was discovered that CONFIG_IP_VS_IPV6 was
the change that introduce this difference in behavor.

The bug report is here:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349768

Which includes a test case in order to reproduce this issue:
https://launchpadlibrarian.net/182765875/lp1349768.sh

We've just recently enabled CONFIG_IP_VS_IPV6, which exposed this issue;
and the user is not using IPV6 functionality.

I've traced through the code and found that this segment in
net/netfilter/ipvs/ip_vs_core.c
function ip_vs_out is what triggers this issue, if commented out the
problem does not occur:

#ifdef CONFIG_IP_VS_IPV6
        if (af == AF_INET6) {
                if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
                        int related;
                        int verdict = ip_vs_out_icmp_v6(skb, &related,
                                                        hooknum, &iph);

                        if (related)
                                return verdict;
                }
        } else
#endif

Printk'ing further into this, I see that ip_vs_out_icmp_v6 utimately
fails as frag_safe_skb_hp return NULL when packets are no longer being
sent with the test case.

Any suggestions for a fix for this issue, or a places to continue
looking? I'd be happy to continue hacking on this and provide testing.

(Resending because I sent to the incorrect ML address...)

Thanks,
--chris j arges
