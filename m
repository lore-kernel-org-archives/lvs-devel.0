From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when
 possible
Date: Thu, 6 Oct 2022 09:47:49 -0300
Message-ID: <Yz7OdfKZeGkpZSKb@ziepe.ca>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=sourceforge.net; s=x; h=In-Reply-To:Content-Type:MIME-Version:References:
 Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:
 Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
 Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:
 List-Subscribe:List-Post:List-Owner:List-Archive;
 bh=eLAvQxPTrW61bFz1sANG5Y81u18aSgNqwRKiQkasIrQ=; b=Zs4PMNWUJ8Gt2N929ZMYSypF0a
 34CSqGZTg+hN99W5bNcUifDKI0Sz/JB+GI6jDxUXNYoRQH0vm0cGlxVhGSi76m3BCsyDpPj4Dqmpz
 2hsIXICsi1XhcufndzsXWOtb+A4RsL1TjxcCX3rh9UmfQAnQqpYP7rKtcvW1dBNw3KVA=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=In-Reply-To:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To
 :From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=eLAvQxPTrW61bFz1sANG5Y81u18aSgNqwRKiQkasIrQ=; b=Vczi0vlgFScmwia5W4D0PNoZ7i
 0iN3Do2nWQVl6iTOmeV4pA5ik+EtEw302iGfeaqjFAPcpBeiR4UYiuX5qaCZRUjYoDCQeoEeRM68z
 MK9Xh3cPaEX1NrEMpNwPdmavChcvjUf60QV3WFCLAFRkS+Q0zlvPwlQdZ4VK+bUWIt0U=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ziepe.ca; s=google;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date;
 bh=eLAvQxPTrW61bFz1sANG5Y81u18aSgNqwRKiQkasIrQ=;
 b=Mjk55TEbLntyF5lT9fSI68nVndM1Msdjat/gJGZygPgfzU+WkmD3YJi9WXVGaCzM6v
 GxLLpAA6PXTqzjvO06yw50CV42lW4n/vIEByFS591YiP94BQoBhbbWQVP56HTGxk5Zgr
 BOk05yP29axd7oq4HdYwQK9SI5EUWt7gxVDMFJ+wkOreCPIVeriBrHDtpGfIe2ngJppN
 JQryL8z0uIEMfGv9GgcIhdNpUKCWmtH1vAJbOQzYFsOAjpmcoQIxgv9D+phyeqT1BAZz
 6oBo+rhyLIIlr94eqFOQOrHm5nD105nysrFzzWFdbvZC9hK7I+vgzgKfrpoAG3/bFvxl
 ry9Q==
Content-Disposition: inline
In-Reply-To: <20221005214844.2699-4-Jason@zx2c4.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Andrew Lunn <andrew@lunn.ch>, "Darrick J . Wong" <djwong@kernel.org>, Ulf Hansson <ulf.hansson@linaro.org>, dri-devel@lists.freedesktop.org, Andrii Nakryiko <andrii@kernel.org>, Hans Verkuil <hverkuil@xs4all.nl>, linux-sctp@vger.kernel.org, "Md . Haris Iqbal" <haris.iqbal@ionos.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Christoph Hellwig <hch@lst.de>, Andy Gospodarek <andy@greyhouse.net>, Sergey Matyukevich <geomatsi@gmail.com>, Rohit Maheshwari <rohitm@chelsio.com>, Michael Ellerman <mpe@ellerman.id.au>, ceph-devel@vger.kernel.org, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Nilesh Javali <njavali@marvell.com>, Jean-Paul Roubelat <jpr@f6fbb.org>, Dick Kennedy <dick.kennedy@broadcom.com>, Jay Vosburgh <j.vosburgh@gmail.com>, Potnuri Bharat Teja <bharat@chelsio.com>, Vinay Kumar Yadav <vinay.yadav@chelsio.com>, linux-nfs@vg

On Wed, Oct 05, 2022 at 11:48:42PM +0200, Jason A. Donenfeld wrote:

> index 14392c942f49..499a425a3379 100644
> --- a/drivers/infiniband/hw/cxgb4/cm.c
> +++ b/drivers/infiniband/hw/cxgb4/cm.c
> @@ -734,7 +734,7 @@ static int send_connect(struct c4iw_ep *ep)
>  				   &ep->com.remote_addr;
>  	int ret;
>  	enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
> -	u32 isn = (prandom_u32() & ~7UL) - 1;
> +	u32 isn = (get_random_u32() & ~7UL) - 1;

Maybe this wants to be written as

(prandom_max(U32_MAX >> 7) << 7) | 7

?

> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> index fd9d7f2c4d64..a605cf66b83e 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> @@ -465,7 +465,7 @@ static int ipoib_cm_req_handler(struct ib_cm_id *cm_id,
>  		goto err_qp;
>  	}
>  
> -	psn = prandom_u32() & 0xffffff;
> +	psn = get_random_u32() & 0xffffff;

 prandom_max(0xffffff + 1) 

?

Jason
