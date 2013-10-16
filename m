From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Tue, 15 Oct 2013 17:39:09 -0700
Message-ID: <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
	 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016002807.GM22321@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :content-type:content-transfer-encoding:mime-version;
        bh=ncCVeu+np5676Rs7JaswOQRp5D6iQALJK6NaIGGtf2o=;
        b=rteV/N25ycZ47w+kSXZUqCyaH+irxf6DrDO2bEEGd7OYPwOQOQEil2sKkD4gQbaWhq
         QX49oEWAhUdR+lH/vUGzmwAuXH7Xdyw2BGSpKbe0r8tu3pzGxACoqpJgzQ92A5u5BptO
         k0FaI6I1k37neVnQXsO2hag4C0npOMLtz6vtTuiYv5E+vkB80DOvQPgKsGdkh0L7Yv9C
         SyzBmL3y7Tu3zh9LL25U1xlJYNgUft3yc8vV3+nk6ZpPny0+PIchY9QVVdqkhloCGfif
         2+ff6lEJYxGvYNk6frSP82mRJ5471zihf75yQ72sS7B4d+INNo/TnKDbgNuU9lNGv6XN
         t6gg==
In-Reply-To: <20131016002807.GM22321@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Mark Brooks <mark@loadbalancer.org>

On Wed, 2013-10-16 at 09:28 +0900, Simon Horman wrote:

> > I guess things like NFQUEUE could happen ?
> 
> Could you expand a little?

This was to point that between IPVS and ipv6 stack we might have a
delay, and daddr was maybe pointed to a freed memory.

IP6CB only uses 24 bytes, so I think you would be safe adding 16 bytes.



