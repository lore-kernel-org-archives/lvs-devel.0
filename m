From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was on
 FIN_WAIT or TIME_WAIT
Date: Tue, 6 Jan 2015 23:06:07 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501062255390.6550@ja.home.ssi.bg>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg> <54883DCA.7050906@redhat.com> <54887B3C.2000709@redhat.com> <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg>
 <548991AF.1050502@redhat.com> <alpine.LFD.2.11.1412112207350.2098@ja.home.ssi.bg> <548AD85D.1070109@redhat.com> <54A301AD.8060002@redhat.com> <alpine.LFD.2.11.1501052326290.11288@ja.home.ssi.bg> <54ABD124.9020504@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <54ABD124.9020504@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com


	Hello,

On Tue, 6 Jan 2015, Marcelo Ricardo Leitner wrote:

> > 	I guess, we here try to avoid old sync message to
> > expire new connection. The problem is that UDP conns and
> > templates are always IP_VS_CONN_F_INACTIVE, may be a TCP+SCTP
> > protocol check is needed.
> 
> Yes, that's the idea, avoiding the old sync messages. I don't think we need a
> check for protocol here because the outer if() (the one that checks daddr and
> dport) wouldn't happen for UDP, right? Unless it was really recycled.. But
> yeah I missed the template case. Perhaps we can just move this block together
> with the previous if(!).

	OK, just make sure patch has short lines (80):

# scripts/checkpatch.pl --strict /tmp/file.patch

> 
>         if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
>                 cp = ip_vs_conn_in_get(param);
>                 if (cp && ((cp->dport != dport) ||
>                            !ip_vs_addr_equal(cp->daf, &cp->daddr, daddr))) {
>                         if (!(flags & IP_VS_CONN_F_INACTIVE)) {
>                                 ip_vs_conn_expire_now(cp);
>                                 __ip_vs_conn_put(cp);
>                                 cp = NULL;
>                         } else {

	I assume we will not stop here sync for some connection that
was normally expired in master but was delayed in backup. TCP sync
starts for EST state, so I think it will hit the above case.

>                                 /* This is the expiration message for the
>                                  * connection that was already replaced, so we
>                                  * just ignore it.
>                                  */
>                                 goto out;
>                         }
>                 }
>         } else {
>                 cp = ip_vs_ct_in_get(param);
>         }

Regards

--
Julian Anastasov <ja@ssi.bg>
