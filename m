From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for IPPROTO_TCP
Date: Thu, 3 May 2018 21:50:49 -0600
Message-ID: <c6714a4f-72c4-51e8-baf5-77505d5fb1a6@gmail.com>
References: <20180419212324.1542504-1-kafai@fb.com>
 <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg>
 <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
 <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg>
 <20180503070114.bcuusvzga45klccs@kafai-mbp>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=1APk9pbicY29cYZW5el6YuHBCUAvtEyuB7Z5YL5JQZI=;
        b=dr3bcJKtwnn+Rf1BlW1ccOS6ljgTrUhiC/6rEn6D7C/CZ1jG3K3Mod5IgGHo7W5n3L
         bpvezIdr+a+peQhyT0rEp2Z1Cmf7ceXeHi1hvzsv0G/+7doXfe7Yn60RBwqY8T4HpPZs
         eEBbKHT8rhJZ/sDThJItCIVzRy4Bk0k1E4NAlQDzKcWi7oDjfkh9Xy7agY446vLWtR1j
         +Sh8ny4ad5c6J9BoPFo3YngBjcQAzTY7Mt9vKaAyLYFW6Az1mA0SilxbxnaN3Os0k7Ym
         2MOaiYkq7kQyFrIKhEjTKzEG4wOBayMVULHWkI4w804EvKjpbUrgqaKBpo1+6Ueatmyf
         wpwQ==
In-Reply-To: <20180503070114.bcuusvzga45klccs@kafai-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Martin KaFai Lau <kafai@fb.com>, Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

On 5/3/18 1:01 AM, Martin KaFai Lau wrote:
> On Wed, May 02, 2018 at 10:30:32PM +0300, Julian Anastasov wrote:
>>
>> 	Hello,
>>
>> On Wed, 2 May 2018, Martin KaFai Lau wrote:
>>
>>> On Wed, May 02, 2018 at 09:38:43AM +0300, Julian Anastasov wrote:
>>>>
>>>> - initial traffic for port 21 does not use GSO. But after
>>>> every packet IPVS calls maybe_update_pmtu (rt->dst.ops->update_pmtu)
>>>> to report the reduced MTU. These updates are stored in fnhe_pmtu
>>>> but they do not go to any route, even if we try to get fresh
>>>> output route. Why? Because the local routes are not cached, so
>>>> they can not use the fnhe. This is what my patch for route.c
>>>> will fix. With this fix FTP-DATA gets route with reduced PMTU.
>>> For IPv6, the 'if (rt6->rt6i_flags & RTF_LOCAL)' gate in
>>> __ip6_rt_update_pmtu() may need to be lifted also.
>>
>> 	Probably. I completely forgot the IPv6 part
>> but as I don't know the IPv6 code enough, it may take
>> some time to understand what can be the problem there...
>> I'm not sure whether everything started with commit 0a6b2a1dc2a2,
>> so that in some configurations before that commit things
>> worked and problem was not noticed.
>>
>> 	I think, we should focus on such direction for IPv6:
>>
>> - do we remember per-VIP PMTU for the local routes
> IPv6 used not to create cache route for DST_HOST route which
> is a /128 route (that includes local /128 route).
> 
> Because of this, it had a bug such that a PMTU for the DST_HOST
> route will trigger dst.ops->update_pmtu() which then set
> an expire on the permanent /128 route instead of a cache
> route.  The permanent route got unexpectedly expired/removed
> later.
> 
> The fix was to allow creating /128 cache route as long as
> it is not RTF_LOCAL in 653437d02f1f and 7035870d1219.  The
> first post spelled out the problem better:
> https://patchwork.ozlabs.org/patch/456050/
> 
> Later, when we only create cache route after seeing PMTU
> in 45e4fd26683c, this RTF_LOCAL checking was carried over
> to __ip6_rt_update_pmtu().
> 
> Out of my head, I don't see issue removing the
> RTF_LOCAL check from __ip6_rt_update_pmtu().
> DavidA, what do you think?

I agree; I think it is fine. A route is route. The IPVS use cases with
local redirects are blurring the line with needs for local routes.

