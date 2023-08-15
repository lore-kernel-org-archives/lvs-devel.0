From: Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v3 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Tue, 15 Aug 2023 15:27:12 -0700
Message-ID: <ZNv7wOmUPpCUFnHA@bombadil.infradead.org>
References: <20230809105006.1198165-1-j.granados@samsung.com>
Mime-Version: 1.0
Return-path: <netdev+bounces-27820-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=aFm90R+tDTFvDBLdwRCYQE4Y41kg8AEvvcWG6AcDlHc=; b=m+Hvj3w2nGUh/z5FvuS2WaFvCP
	E9VTMTriBBsaYE1DW7gg45cfxPOHyZo+qnJy5YDlRNwx/8IEd6QSy1kFsWmCaI6Ayn2U1e18uzlwr
	1+Iy9qd60pMllaFg/MtWE7G1QlLCx82ZCCAIzB8O5VbfxRwp9DMOrRwt9Ca10lMltY10Km8PtNXu/
	L6WobTanJRf/8tEi6GPMdzrRmGdH4Dw9KByfrbTqLo06X3hWeNkANUIM+i1BPRo1BIMLMC8dpsrXD
	Hz59LovBcm5X+3VH7+EtsxrFP7ARkSjVCRHEyC2IZkI52jv17UdFdX7UcYwBUjCHLaKBVrUaPumbs
	W9PGgB4A==;
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20230809105006.1198165-1-j.granados@samsung.com>
Sender: Luis Chamberlain <mcgrof@infradead.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joel Granados <joel.granados@gmail.com>
Cc: rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, willy@infradead.org, Jan Karcher <jaka@linux.ibm.com>, Wen Gu <guwen@linux.alibaba.com>, Simon Horman <horms@verge.net.au>, Tony Lu <tonylu@linux.alibaba.com>, linux-wpan@vger.kernel.org, Matthieu Baerts <matthieu.baerts@tessares.net>, Christian Borntraeger <borntraeger@linux.ibm.com>, mptcp@lists.linux.dev, Heiko Carstens <hca@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Will Deacon <will@kernel.org>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>, linux-kernel@vger.kernel.org, Alexander Gordeev <agordeev@linux.ibm.com>, linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-hams@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, coreteam@netfilter.org

On Wed, Aug 09, 2023 at 12:49:52PM +0200, Joel Granados wrote:
> What?
> These commits set things up so we can start removing the sentinel elements.
> They modify sysctl and net_sysctl internals so that registering a ctl_table
> that contains a sentinel gives the same result as passing a table_size
> calculated from the ctl_table array without a sentinel. We accomplish this by
> introducing a table_size argument in the same place where procname is checked
> for NULL. The idea is for it to keep stopping when it hits ->procname == NULL,
> while the sentinel is still present. And when the sentinel is removed, it will
> stop on the table_size (thx to jani.nikula@linux.intel.com for the discussion
> that led to this). This allows us to remove sentinels from one (or several)
> files at a time.
> 
> These commits are part of a bigger set containing the removal of ctl_table sentinel
> (https://github.com/Joelgranados/linux/tree/tag/sysctl_remove_empty_elem_V3).
> The idea is to make the review process easier by chunking the 65+ commits into
> manageable pieces.

Thanks, I've dropped the old set and merged this updated one onto sysctl-next.

  Luis

