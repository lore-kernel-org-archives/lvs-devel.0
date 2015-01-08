From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was
 on FIN_WAIT or TIME_WAIT
Date: Thu, 08 Jan 2015 10:35:37 -0200
Message-ID: <54AE7999.4020809@redhat.com>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg> <54883DCA.7050906@redhat.com> <54887B3C.2000709@redhat.com> <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg> <548991AF.1050502@redhat.com> <alpine.LFD.2.11.1412112207350.2098@ja.home.ssi.bg> <548AD85D.1070109@redhat.com> <54A301AD.8060002@redhat.com> <alpine.LFD.2.11.1501052326290.11288@ja.home.ssi.bg> <54ABD124.9020504@redhat.com> <alpine.LFD.2.11.1501062255390.6550@ja.home.ssi.bg> <54AD5638.8060201@redhat.com> <alpine.LFD.2.11.1501072126150.2105@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1501072126150.2105@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com

Hi,

On 07-01-2015 17:31, Julian Anastasov wrote:
>
> 	Hello,
>
> On Wed, 7 Jan 2015, Marcelo Ricardo Leitner wrote:
>
>> On 06-01-2015 19:06, Julian Anastasov wrote:
>>>
>>> On Tue, 6 Jan 2015, Marcelo Ricardo Leitner wrote:
>>>
>>>>
>>>>           if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
>>>>                   cp = ip_vs_conn_in_get(param);
>>>>                   if (cp && ((cp->dport != dport) ||
>>>>                              !ip_vs_addr_equal(cp->daf, &cp->daddr,
>>>>                           daddr))) {
>>>>                           if (!(flags & IP_VS_CONN_F_INACTIVE)) {
>>>>                                   ip_vs_conn_expire_now(cp);
>>>>                                   __ip_vs_conn_put(cp);
>>>>                                   cp = NULL;
>>>>                           } else {
>>>
>>> 	I assume we will not stop here sync for some connection that
>>> was normally expired in master but was delayed in backup. TCP sync
>>> starts for EST state, so I think it will hit the above case.
>>
>> You mean that we could end up ignoring a sync msg that we shouldn't ignore?
>
> 	Yes, that was my worry but I don't see how the code
> can fail, so it looks fine to me.

Ok, cool. I'll do more tests and probably post this by next week.

Thanks Julian.

Regards,
Marcelo

