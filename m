From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 12:03:04 +0200
Message-ID: <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220868186; bh=xMXN3QLaDAyLiNHVv4xadoIfWR8=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=cV7qsPcXZ2iKu4l9y1A21w2U2Xq05v4I
	hxPptKcfIlQJ5MqRE5L2M5dzGeS7K0EsPDxOGevLDqTgqn472oOv2g==
In-Reply-To: <20080908020420.313463898@vergenet.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, =?ISO-8859-1?Q?Siim_P=C3=B5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 8, 2008 at 4:04 AM, Simon Horman wrote:
> Hi,
>
> The impetus for this series of patches is Julian Anastasov noting
> that "load balance IPv4 connections from a local process" checks
> for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
> even on loopback traffic, but that rather partial checksums are
> possible.
>
> The first patch in this series is a proposed solution to handle
> partial checksums for both TCP and UDP.
>
> The other two patches clean things up a bit.
>
> I have not tested this code beyond compilation yet.

After some first tests, remote connections are still working, but not
local ones from the director. The TCP handshake works and the
connection is established, but all following packets arriving at the
real server have an incorrect TCP checksum.

Btw., this happens both with and without this last series of patches,
so I can't get the local client feature working at all. Looking at it
further...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
