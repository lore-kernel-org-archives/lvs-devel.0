From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 12/15] ipvlan: Cache net in ipvlan_process_v4_outbound
 and ipvlan_process_v6_outbound
Date: Tue, 6 Oct 2015 18:24:06 -0700
Message-ID: <CAF2d9jjqF=MaZtN5znWqNOCmYocLzPV_g6i-PWYye3CcYy0g6Q@mail.gmail.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org> <1444157595-28816-12-git-send-email-ebiederm@xmission.com>
 <CAF2d9ji4UNrYpnjrAPq3sGH_JBpT=HQTdBCHUV8n45a3HF_Chg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=Fz69R0aVf3WfevT4lFT4HXY8wnwdSV3RK5gJmVigdQs=;
        b=BeQhVa6WwRr0kbOldYBO8zFeXGXsdg3Cz7Lhg0tnoLYGr4gdow7gJfblg7bP9ZEzAT
         twn9QjYrHYJLmtvMHcMsloYNl/qK9k8fsYJUblxhEuyG3N9aUYJNLP1lOw0tn6R5NWAj
         59PCwcvCeAffZ5yoXtHDyE7HW7rO3Y4l66EzQP2LUwPfwcYEGrykPGydEVTNCvWgpBv9
         qvdu+lfL9cD1D6gIgTc1S0UySACBNjp8uf5ao/6Oc1oONQLIp36sQS2Dc9zAcd6vJ9LH
         Db4kzNnFo6hp8Aw41Bpv1k+C0vCGcs/O/dKGGDOnKKH8PmdRb5+EuyYmka/UxFmUPWnE
         JJJA==
In-Reply-To: <CAF2d9ji4UNrYpnjrAPq3sGH_JBpT=HQTdBCHUV8n45a3HF_Chg@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, linux-netdev <netdev@vger.kernel.org>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

On Tue, Oct 6, 2015 at 6:19 PM, Mahesh Bandewar <maheshb@google.com> wrote:
> On Tue, Oct 6, 2015 at 11:53 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Compute net once in ipvlan_process_v4_outbound and ipvlan_process_v6_outbound
>> and store it in a variable so that net does not need to be recomputed next time
>> it is used.
>>
> It's used exactly once at this moment so don't know what "next time"
> is. Do you have any additional patch(es) planned?
>
OK. Got it! I was little early in sending that and did not look at the
entire patch-series.

>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  drivers/net/ipvlan/ipvlan_core.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
>> index 75dcf36c0366..976f30b291f6 100644
>> --- a/drivers/net/ipvlan/ipvlan_core.c
>> +++ b/drivers/net/ipvlan/ipvlan_core.c
>> @@ -344,6 +344,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
>>  {
>>         const struct iphdr *ip4h = ip_hdr(skb);
>>         struct net_device *dev = skb->dev;
>> +       struct net *net = dev_net(dev);
>>         struct rtable *rt;
>>         int err, ret = NET_XMIT_DROP;
>>         struct flowi4 fl4 = {
>> @@ -354,7 +355,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
>>                 .saddr = ip4h->saddr,
>>         };
>>
>> -       rt = ip_route_output_flow(dev_net(dev), &fl4, NULL);
>> +       rt = ip_route_output_flow(net, &fl4, NULL);
>>         if (IS_ERR(rt))
>>                 goto err;
>>
>> @@ -381,6 +382,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
>>  {
>>         const struct ipv6hdr *ip6h = ipv6_hdr(skb);
>>         struct net_device *dev = skb->dev;
>> +       struct net *net = dev_net(dev);
>>         struct dst_entry *dst;
>>         int err, ret = NET_XMIT_DROP;
>>         struct flowi6 fl6 = {
>> @@ -393,7 +395,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
>>                 .flowi6_proto = ip6h->nexthdr,
>>         };
>>
>> -       dst = ip6_route_output(dev_net(dev), NULL, &fl6);
>> +       dst = ip6_route_output(net, NULL, &fl6);
>>         if (dst->error) {
>>                 ret = dst->error;
>>                 dst_release(dst);
>> --
>> 2.2.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
