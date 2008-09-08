From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 17:32:47 +0200
Message-ID: <f4845fc0809080832w69f8aab2q12b63e0a8f6f1fdf@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <20080908104120.GB5795@verge.net.au>
	 <20080908114258.GA29477@google.com>
	 <20080908115734.GA24228@verge.net.au>
	 <20080908120413.GB24228@verge.net.au>
	 <f4845fc0809080514i6118cc4bt6510da3d93483156@mail.gmail.com>
	 <20080908123450.GC24228@verge.net.au>
	 <f4845fc0809080612n77a77791v8ccbac8178ecf1f4@mail.gmail.com>
	 <20080908132049.GA11119@verge.net.au>
	 <f4845fc0809080642t1629ed27ld9087d788828d24d@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220887970; bh=3n0xeWL1U3uXfyHKcXueWoWI2r0=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=WR3SAEGDdStoV0lpdmM2dS7JZY0Rayo1
	8jaFGdoymCy06XeoP2ZFXD1GaoFVvmpXIiogRxePsxajLqeBUl5fnA==
In-Reply-To: <f4845fc0809080642t1629ed27ld9087d788828d24d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 8, 2008 at 3:42 PM, Julius Volz <juliusv@google.com> wrote:
> On Mon, Sep 8, 2008 at 3:20 PM, Simon Horman <horms@verge.net.au> wrote:
>> I'm not so concerned about IPv6 local not working for now -
>> its a combination of two new features. And hopefully we
>> can iron it out in the not to distant future anyway.
>
> Yes, probably just some minor bug...

Actually, it wasn't even a kernel bug, but a configuration error - I
was using LVS/NAT, but still had the dummy0 interface with the IPv6
VIP configured on the real server (from the DR case). And in the local
client case, the source address is the VIP, so the real server just
delivered the response to itself.

Now I can confirm that everything is working (without your last two
patches and with the one removing the wrong ip_route_me_harder)!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
