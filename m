From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 15:42:17 +0200
Message-ID: <f4845fc0809080642t1629ed27ld9087d788828d24d@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com>
	 <20080908104120.GB5795@verge.net.au>
	 <20080908114258.GA29477@google.com>
	 <20080908115734.GA24228@verge.net.au>
	 <20080908120413.GB24228@verge.net.au>
	 <f4845fc0809080514i6118cc4bt6510da3d93483156@mail.gmail.com>
	 <20080908123450.GC24228@verge.net.au>
	 <f4845fc0809080612n77a77791v8ccbac8178ecf1f4@mail.gmail.com>
	 <20080908132049.GA11119@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220881339; bh=beFF1SPAjWOgWSNmeuFpOwFTPe4=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=wXuCBuvgsbDYRKxky9FUjedTZryQCr1t
	PfzpFq4/eq/I6psMLSb7KlGUfULma0/3aoEdpHMjw/aFUnrDM6X62Q==
In-Reply-To: <20080908132049.GA11119@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 8, 2008 at 3:20 PM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 08, 2008 at 03:12:39PM +0200, Julius Volz wrote:
>> On Mon, Sep 8, 2008 at 2:34 PM, Simon Horman <horms@verge.net.au> wrote:
>> > On Mon, Sep 08, 2008 at 02:14:12PM +0200, Julius Volz wrote:
>> >> I'm actually looking at that case now (4856c84c1358b, but with the fix
>> >> above). It seems that the NAT isn't working (DR works, by the way!).
>> >> At least the first packet arriving at the real server still has the
>> >> client's IP as the source (in the v6 case)...
>> >
>> > Ok, I'm looking at NAT with 4856c84c1358b + that fix too too,
>> > but on v4 :-)
>> >
>> >> Let's wait with reverting the local client patches until tomorrow...
>> >> maybe I can find the problem until then.
>> >
>> > Ok, I was just concerned that this might hold up merging
>> > your code into Dave's tree for too long, thats all.
>>
>> Ok, with my last patch (and your two/three last ones reverted), I get
>> everything working except IPv6 with a local client...
>
> Ok, that is good news :-)
>
> Sorry for the stuff up. That bugus ip_route_me_harder() call
> was caused by me trying to merge the IPv6 patches with the local
> client patches.

No problem!

> I'm not so concerned about IPv6 local not working for now -
> its a combination of two new features. And hopefully we
> can iron it out in the not to distant future anyway.

Yes, probably just some minor bug...

> I'll drop CSUM2/3 and 3/3 for now, they aren't essential and
> it really ought to be a matter of (me) sitting down and fixing
> some correctness issues.

Ok!

> Its the end of my day now. I'll try and update lvs-next-2.6 into
> a working state in the morning.

Yes, let's stabilize it a bit... have a nice evening!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
