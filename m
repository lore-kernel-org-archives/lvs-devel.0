From: Joanne Koong <joannekoong@fb.com>
Subject: Re: [PATCH net-next] net: Enable some sysctls for the userns root
 with privilege
Date: Tue, 7 Dec 2021 14:16:43 -0800
Message-ID: <2f0757f8-797f-644b-50ee-0c1aef8fe865@fb.com>
References: <20211203032815.339186-1-xu.xin16@zte.com.cn>
 <20211206164520.51f8a2d8@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
 <61af0ac4.1c69fb81.6badc.a755@mx.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=message-id : date :
 subject : to : cc : references : from : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=2tKsq/qL/r+NhwepSb+uxf1+QugrAKFwO0FY1iRlKmE=;
 b=XWRecB0LHq59slRGxV2y7kcy4c87QP1TEDscRMPN2zUARQK+HX7UPub6+MnV3zEfzRm3
 IdxqoSmbizZrpLXSleGNzsEIjeRdCejYH5bbUm1Z1kOA9E3adnRpH4hgh+6tI7X7eo9L
 +FBTRFWiMdh2vyAunxAa9mz5ToFRjlLXQTY= 
Content-Language: en-US
In-Reply-To: <61af0ac4.1c69fb81.6badc.a755@mx.google.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: CGEL <cgel.zte@gmail.com>, Jakub Kicinski <kuba@kernel.org>
Cc: davem@davemloft.net, alex.aring@gmail.com, stefan@datenfreihafen.org, yoshfuji@linux-ipv6.org, dsahern@kernel.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, steffen.klassert@secunet.com, herbert@gondor.apana.org.au, daniel@iogearbox.net, roopa@nvidia.com, yajun.deng@linux.dev, chinagar@codeaurora.org, xu.xin16@zte.com.cn, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Eric Biederman <ebiederm@xmission.com>

On 12/6/21 11:18 PM, CGEL wrote:

> On Mon, Dec 06, 2021 at 04:45:20PM -0800, Jakub Kicinski wrote:
>> On Fri,  3 Dec 2021 03:28:15 +0000 cgel.zte@gmail.com wrote:
>>> From: xu xin <xu.xin16@zte.com.cn>
>>>
>>> Enabled sysctls include the followings:
>>> 1. net/ipv4/neigh/<if>/*
>>> 2. net/ipv6/neigh/<if>/*
>>> 3. net/ieee802154/6lowpan/*
>>> 4. net/ipv6/route/*
>>> 5. net/ipv4/vs/*
>>> 6. net/unix/*
>>> 7. net/core/xfrm_*
>>>
>>> In practical work, some userns with root privilege have needs to adjust
>>> these sysctls in their own netns, but limited just because they are not
>>> init user_ns, even if they are given root privilege by docker -privilege.
>> You need to justify why removing these checks is safe. It sounds like
>> you're only describing why having the permissions is problematic, which
>> is fair but not sufficient to just remove them.
>>
> Hi, Jakub
> My patch is a little radical. I just saw Eric's previous reply to
> Alexander(https://lore.kernel.org/all/87pmsqyuqy.fsf@disp2133/).
> These were disabled because out of an abundance of caution.
>
> My original intention is to enable part of syscyls about neighbor which
> I think was safe, but I will try to figure out which of these sysctls
> are safe to be enabled.
>

A team at my company has a use case for needing to set the unix sysctls,
so I submitted a patch for enabling the unix sysctl here
https://lore.kernel.org/netdev/20211207202101.2457994-1-joannekoong@fb.com/T/#u

[...]
>>> Signed-off-by: xu xin <xu.xin16@zte.com.cn>
>>> ---
>>>   net/core/neighbour.c                | 4 ----
>>>   net/ieee802154/6lowpan/reassembly.c | 4 ----
>>>   net/ipv6/route.c                    | 4 ----
>>>   net/netfilter/ipvs/ip_vs_ctl.c      | 4 ----
>>>   net/netfilter/ipvs/ip_vs_lblc.c     | 4 ----
>>>   net/netfilter/ipvs/ip_vs_lblcr.c    | 3 ---
>>>   net/unix/sysctl_net_unix.c          | 4 ----
>>>   net/xfrm/xfrm_sysctl.c              | 4 ----
>>>   8 files changed, 31 deletions(-)
>
