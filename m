From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Tue, 9 Sep 2008 11:30:29 +0200
Message-ID: <f4845fc0809090230h1cbc01ev45c6ab4bdba61955@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <20080908234028.GF13048@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220952632; bh=WxfwL+LCWdvGVvmnJnq9vbZtkjk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=SvvhyVnE2HhObyqPLVVDQAhefOi+5ryU
	K03f2uIobAvhG8SfTGLkEA46VXcM8YArPtmqfmM6MjIYtmKtXpBVPQ==
In-Reply-To: <20080908234028.GF13048@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Tue, Sep 9, 2008 at 1:40 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 08, 2008 at 12:04:20PM +1000, Simon Horman wrote:
>> Hi,
>>
>> The impetus for this series of patches is Julian Anastasov noting
>> that "load balance IPv4 connections from a local process" checks
>> for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
>> even on loopback traffic, but that rather partial checksums are
>> possible.
>>
>> The first patch in this series is a proposed solution to handle
>> partial checksums for both TCP and UDP.
>>
>> The other two patches clean things up a bit.
>>
>> I have not tested this code beyond compilation yet.
>
> After extensive testing by Julius Volz and limited testing by myself, I
> have applied the first patch, which does indeed allow packets with
> PARTIAL_CHECKSUM to work, to lvs-next-2.6. I have dropped the second two
> patches which produce bogus checksums.

Great, thanks! I have tested TCP+UDP, local+remote clients, v4+v6,
NAT+DSR+TUN in all combinations that are expected to be working and
found no problems.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
