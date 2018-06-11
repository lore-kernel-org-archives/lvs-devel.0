From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] ipv6: allow PMTU exceptions to local routes
Date: Mon, 11 Jun 2018 09:07:34 -0700
Message-ID: <20180611160734.swbdij7daduxfmt2@kafai-mbp>
References: <20180610230254.6347-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=date : from : to : cc :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=facebook; bh=Z42t/1oFxSRffC/rnmCpATd29eu+vEmlFqUU33iWMI8=;
 b=dzFPJUpP3WaLvBO8B9JL1LjqM4WrhSqKekYgNHG1zAuA03qxWTsDsrp3JiVLsOU399ra
 1neThIFLhyWiK+sWYaP+bOYT6hlk1TL0fa56yQK21u6ChfUkR8ZAkcBddEYlHpf0EIRU
 nBmqXrtYWftY4gWjTLb0e+NiDyG6YbRzRUo= 
Content-Disposition: inline
In-Reply-To: <20180610230254.6347-1-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, kernel-team@fb.com, lvs-devel@vger.kernel.org

On Mon, Jun 11, 2018 at 02:02:54AM +0300, Julian Anastasov wrote:
> IPVS setups with local client and remote tunnel server need
> to create exception for the local virtual IP. What we do is to
> change PMTU from 64KB (on "lo") to 1460 in the common case.
> 
> Suggested-by: Martin KaFai Lau <kafai@fb.com>
> Fixes: 45e4fd26683c ("ipv6: Only create RTF_CACHE routes after encountering pmtu exception")
> Fixes: 7343ff31ebf0 ("ipv6: Don't create clones of host routes.")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Martin KaFai Lau <kafai@fb.com>
