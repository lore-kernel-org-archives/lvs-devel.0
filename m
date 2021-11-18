From: zhenggy <zhenggy@chinatelecom.cn>
Subject: Re: [PATCH] ipvs: remove unused variable for ip_vs_new_dest
Date: Thu, 18 Nov 2021 09:09:17 +0800
Message-ID: <97494860-f9d3-44e6-7515-0031ea64f86c@chinatelecom.cn>
References: <1636112380-11040-1-git-send-email-zhenggy@chinatelecom.cn>
 <25e945b7-9027-43cb-f79c-573fdce42a26@ssi.bg>
 <20211114180206.GA2757@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: zhenggy@chinatelecom.cn
In-Reply-To: <20211114180206.GA2757@vergenet.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, pablo@netfilter.org
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

Thanks for review.

=D4=DA 2021/11/15 2:02, Simon Horman =D0=B4=B5=C0:
> On Sat, Nov 13, 2021 at 11:56:36AM +0200, Julian Anastasov wrote:
>>
>> 	Hello,
>>
>> On Fri, 5 Nov 2021, GuoYong Zheng wrote:
>>
>>> The dest variable is not used after ip_vs_new_dest anymore in
>>> ip_vs_add_dest, do not need pass it to ip_vs_new_dest, remove it.
>>>
>>> Signed-off-by: GuoYong Zheng <zhenggy@chinatelecom.cn>
>>
>> 	Looks good to me for -next, thanks!
>>
>> Acked-by: Julian Anastasov <ja@ssi.bg>
>=20
> Thanks GuoYong,
>=20
> Acked-by: Simon Horman <horms@verge.net.au>
>=20
> Pablo, please consider this for nf-next at your convenience.
>=20
>>
>>> ---
>>>  net/netfilter/ipvs/ip_vs_ctl.c | 7 ++-----
>>>  1 file changed, 2 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
>>> index e62b40b..494399d 100644
>>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>>> @@ -959,8 +959,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *=
ipvs)
>>>   *	Create a destination for the given service
>>>   */
>>>  static int
>>> -ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern =
*udest,
>>> -	       struct ip_vs_dest **dest_p)
>>> +ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern =
*udest)
>>>  {
>>>  	struct ip_vs_dest *dest;
>>>  	unsigned int atype, i;
>>> @@ -1020,8 +1019,6 @@ static void ip_vs_trash_cleanup(struct netns_ipvs=
 *ipvs)
>>>  	spin_lock_init(&dest->stats.lock);
>>>  	__ip_vs_update_dest(svc, dest, udest, 1);
>>> =20
>>> -	*dest_p =3D dest;
>>> -
>>>  	LeaveFunction(2);
>>>  	return 0;
>>> =20
>>> @@ -1095,7 +1092,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs=
 *ipvs)
>>>  		/*
>>>  		 * Allocate and initialize the dest structure
>>>  		 */
>>> -		ret =3D ip_vs_new_dest(svc, udest, &dest);
>>> +		ret =3D ip_vs_new_dest(svc, udest);
>>>  	}
>>>  	LeaveFunction(2);
>>> =20
>>> --=20
>>> 1.8.3.1
>>
>> Regards
>>
>> --
>> Julian Anastasov <ja@ssi.bg>
>>
