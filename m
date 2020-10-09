From: Evgeny B <abt-admin@mail.ru>
Subject: Re: Fw: [Bug 209427] New: Incorrect timestamp cause packet to be
 dropped
Date: Fri, 9 Oct 2020 13:22:03 +0300
Message-ID: <cbacae19-8a84-b7a9-8e92-1ca6b22b8b65@mail.ru>
References: <20200929103532.0ecbc3b3@hermes.local>
 <8e1a8be5-4123-ea86-80f2-16027cfa021c@gmail.com>
 <alpine.LFD.2.23.451.2009302010190.4321@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=mail.ru; s=mail2;
        h=Content-Transfer-Encoding:Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:Subject; bh=YcSQ4rsmBfLfJBWniWKYCsnWwlWlYuVtOo+n0oO/a2k=;
        b=uS0fb6leUOaOyga1vKeGodM4P01km07R/kbT17bSYZtk6Ij2Q3GNDs7W0rUBdp0jrVJN674q0qsuipsreg0qcwJ2Fo+Da+Cm56NyRJHsev7oGyl8N25GJGWT4Cy1r4XdO70z7AvHBLLUkNZMw9eJZYpUaXPAjkX3dCp7Bp7+pK8=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=mail.ru; s=mail3;
        h=Content-Transfer-Encoding:Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:Subject:From:Subject:Content-Type:Content-Transfer-Encoding:To:Cc; bh=YcSQ4rsmBfLfJBWniWKYCsnWwlWlYuVtOo+n0oO/a2k=;
        b=qd4Fb0UgTwXdpNg7JOObYlViQTotQmFZkzKKLCUXBSs7Qgx9J13LyY2c2zGJNvRc7SRVW0bf6WSMF49h2HLjPZPFj0/7kLL844rF2tmL4QUlv+/O881oeRfNWM++AcTYMzDTQz9VxLnemvXIpHtkcFFWOqmb78ECid3dHEqv1hc=;
In-Reply-To: <alpine.LFD.2.23.451.2009302010190.4321@ja.home.ssi.bg>
Content-Language: en-US
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: 
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

I just realized all my messages were bounced by mail server, this is 
last try


This fix works, however they should be applied for each of ipvs_xmit 
functions (e.g. ip_vs_nat_xmit(), ip_vs_dr_xmit(), etc.)

I look forward to seeing the patch in ml-5.x

Thank you!


On 9/30/2020 8:17 PM, Julian Anastasov wrote:
> 	Hello,
>
> On Wed, 30 Sep 2020, Eric Dumazet wrote:
>
>> On 9/29/20 7:35 PM, Stephen Hemminger wrote:
>>>
>>> then I noticed that in some cases skb->tstamp is equal to real ts whereas in
>>> the regular cases where a packet pass through it's time since kernel boot. This
>>> doesn't make any sense for me as this condition is satisfied constantly
>>>
>>> net/sched/sch_fq.c:439
>>> static bool fq_packet_beyond_horizon(const struct sk_buff *skb,
>>>                                      const struct fq_sched_data *q)
>>> {
>>>          return unlikely((s64)skb->tstamp > (s64)(q->ktime_cache + q->horizon));
>>> }
>>>
>>> Any ideas on what it can be?
>>>
>> Thanks for the detailed report !
>>
>> I suspect ipvs or bridge code needs something similar to the fixes done in
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=de20900fbe1c4fd36de25a7a5a43223254ecf0d0
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=41d1c8839e5f8cb781cc635f12791decee8271b7
>>
>> The reason for that is that skb->tstamp can get a timestamp in input path,
>> with a base which is not CLOCK_MONOTONIC, unfortunately.
>>
>> Whenever a packet is forwarded, its tstamp must be cleared.
>>
>> Can you try :
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
>> index b00866d777fe0e9ed8018087ebc664c56f29b5c9..11e8ccdae358a89067046efa62ed40308b9e06f9 100644
>> --- a/net/netfilter/ipvs/ip_vs_xmit.c
>> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
>> @@ -952,6 +952,8 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
>>   
>>          ip_vs_drop_early_demux_sk(skb);
>>   
>> +       skb->tstamp = 0;
>> +
> 	Should be after all skb_forward_csum() calls in ip_vs_xmit.c
>
>>          if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
>>                  new_skb = skb_realloc_headroom(skb, max_headroom);
>>                  if (!new_skb)
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
