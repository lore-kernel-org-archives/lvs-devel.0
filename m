From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 23:22:42 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1101252317280.1690@ja.ssi.bg>
References: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com> <20110125050535.GB7183@verge.net.au> <4D3EA526.5030704@trash.net> <20110125130933.GA2841@verge.net.au> <20110125131558.GB2841@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110125131558.GB2841@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, Changli Gao <xiaosuo@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Hello,

On Tue, 25 Jan 2011, Simon Horman wrote:

>> Hi Patrick,
>>
>> I'm a little unsure how you would like me to differentiate
>> between fixes for 2.6.38 - e.g. my previous two pull requests.
>> And patches intended for 2.6.39.
>>
>> In any case I will send a pull request that includes
>> Changli's change against nf-next-2.6.
>
> Actually, I realise that Changli's change is actually
> 2.6.38 material. I'll send a pull request. Please ignore
> my noise about 2.6.39.

 	Simon, I don't see IPVS netns work in 2.6.38-rc2,
so these changes are not for 2.6.38-rc.

Regards

--
Julian Anastasov <ja@ssi.bg>
