From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [f2fs-dev] [PATCH v1 3/5] treewide: use get_random_u32() when
 possible
Date: Thu, 6 Oct 2022 16:01:11 +0300
Message-ID: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com>
 <20221006084331.4bdktc2zlvbaszym@quack3>
 <Yz7LCyIAHC6l5mG9@zx2c4.com>
Mime-Version: 1.0
Return-path: <linux-crypto-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1665061302; x=1696597302;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=Ru6CnBvVhIEhYJCAeuuxpRt9HHeJLOxAuoa9BjBuh8k=;
  b=AGWKWrAmNTte351h2k1feYl2fEi8rMwITVCJk7pNUXa1Ng0fQ3b2azOq
   uKuvJLxK0mA9Tqu3UQrxcvZhNBZH7+ufyXr/eCl51aK2E+6alzDUNMpev
   Nal/AmQePVXxf51aw66W9WRCAYm+XU/TtJLHLlzK0fLBMpvOkNSKnYU6a
   G0RPB2YNDasi333P00LsC+HLiCjUDiLmBkQrJ9Dt5KAHtZ7QeMOcScwI0
   yVVxu3xrA0z8zp+mB6pCuwFd+t1IPnDGoJrgOtk/mfFAE1KbrDX96OsuA
   Q6dzk7SPLhjyK1/yFBt+FIYuNforlaW4X0SnFFSBR/uzfXEGd3cKuEo3f
   g==;
Content-Disposition: inline
In-Reply-To: <Yz7LCyIAHC6l5mG9@zx2c4.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Lunn <andrew@lunn.ch>, "Darrick J . Wong" <djwong@kernel.org>, Ulf Hansson <ulf.hansson@linaro.org>, dri-devel@lists.freedesktop.org, Andrii Nakryiko <andrii@kernel.org>, Hans Verkuil <hverkuil@xs4all.nl>, linux-sctp@vger.kernel.org, "Md . Haris Iqbal" <haris.iqbal@ionos.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Christoph Hellwig <hch@lst.de>, Andy Gospodarek <andy@greyhouse.net>, Sergey Matyukevich <geomatsi@gmail.com>, Rohit Maheshwari <rohitm@chelsio.com>, Michael Ellerman <mpe@ellerman.id.au>, ceph-devel@vger.kernel.org, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Nilesh Javali <njavali@marvell.com>, Jean-Paul Roubelat <jpr@f6fbb.org>, Dick Kennedy <dick.k>

On Thu, Oct 06, 2022 at 06:33:15AM -0600, Jason A. Donenfeld wrote:
> On Thu, Oct 06, 2022 at 10:43:31AM +0200, Jan Kara wrote:

...

> > The code here is effectively doing the
> > 
> > 	parent_group = prandom_u32_max(ngroups);
> > 
> > Similarly here we can use prandom_u32_max(ngroups) like:
> > 
> > 		if (qstr) {
> > 			...
> > 			parent_group = hinfo.hash % ngroups;
> > 		} else
> > 			parent_group = prandom_u32_max(ngroups);
> 
> Nice catch. I'll move these to patch #1.

I believe coccinelle is able to handle this kind of code as well, so Kees'
proposal to use it seems more plausible since it's less error prone and more
flexible / powerful.

-- 
With Best Regards,
Andy Shevchenko


