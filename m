From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] ipvs: change some __constant_htons() to htons()
Date: Tue, 16 Sep 2008 17:31:39 +0200
Message-ID: <f4845fc0809160831i6868459en6610a7e8b2204367@mail.gmail.com>
References: <48CFCC8F.1040702@hp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221579101; bh=HPMd+8LZte+wbRumMLQs4PbcpBo=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=ILhgcjE/x9oKCLpb1FvXdk2kOnVVKJDs
	pT8oTO159sMUeX2f+YCkb6qkACUytH2FIfGiz0M6ia6vDz5gK4sk4w==
In-Reply-To: <48CFCC8F.1040702@hp.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Brian Haley <brian.haley@hp.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Tue, Sep 16, 2008 at 5:11 PM, Brian Haley <brian.haley@hp.com> wrote:
> Change __contant_htons() to htons() in the IPVS code when not in an
> initializer.
>
> -Brian
>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Thanks. I somehow missed that in the patch series that got in,
although you mentioned it before, sorry!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
