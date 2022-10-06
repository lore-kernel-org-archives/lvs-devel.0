From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v1 1/5] treewide: use prandom_u32_max() when
 possible
Date: Thu, 6 Oct 2022 16:05:21 +0300
Message-ID: <Yz7SkWBbabFQrecB@smile.fi.intel.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-2-Jason@zx2c4.com>
 <202210052035.A1020E3@keescook> <Yz7N5WsqmKiUl+6b@zx2c4.com>
 <Yz7QN3cbKABexzoB@ziepe.ca>
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
 bh=0ENsN90teNsuQpmekN7b+hdYLbg48hC1jdG1eR+cyBQ=; b=KcQYDmMwVEc4O6qGR2weV+w8Zx
 A5GhrtJbClpcTuDsdENxmLzNWWW50r1qHEoAIophu26tpsCfT7aFxzG6RF3idRbExRYYUDK8UvCe3
 7PlY/oA4J4+MVDP4KweuFhTET9qWl7r5ZKL+J3hKIgIoXKaTkT7lyD1T9w+XI1SAY0YY=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=In-Reply-To:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To
 :From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=0ENsN90teNsuQpmekN7b+hdYLbg48hC1jdG1eR+cyBQ=; b=i2W1GFAXX5h/gBVwQFPAY2+wg4
 rW+ZvWzdvdZwaHomboYshI5gxToT4K2xrj9v/YNHGcBEmAaJLzPm5Cpij5UuVfPOCd2TzoiAPfEM8
 Vz76BVv+ad5UnCUZENttCQFsHymIK044gHaTa6x+ThJkmH3F0cLSmN4H/o11dvknl2Rs=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
 d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
 t=1665061561; x=1696597561;
 h=date:from:to:cc:subject:message-id:references:
 mime-version:in-reply-to;
 bh=FGTLdaiXSBCapn2JjYMa8Pm3byrwndmRCKrokbx26S8=;
 b=RJ4xz9xJXLhCVBiqAIf0QUhbMeuRW4kmqo0D2fUDgDiNO/551/oMPh4/
 7Gs9NHulGrbI/j97CJaxqPgJPcjC4qViSrKaGg6KKfwOvCnbceWby/bmf
 TX8i5mEUraEgTYrWx1ZuPGccqzMhlmccEPpdZdpIkwfp6I8cjkAMB82jh
 z828S2ZLUo1Gfjk7ZynLBuvff/tNleSBiNvn7rp6pvfDBW7fFLaezMP07
 yl4OV+HqZjLLj8MYv0FdztpflBf7eM2PFT8Pv6DXGBrMkr98m9qNPyTWa
 Z9wDYH42I+Z96Hb8xPAc414gdD0K5CesH2usSF4YqX5HluC3MOUixVm8l Q==;
Content-Disposition: inline
In-Reply-To: <Yz7QN3cbKABexzoB@ziepe.ca>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Lunn <andrew@lunn.ch>, "Darrick J . Wong" <djwong@kernel.org>, Ulf Hansson <ulf.hansson@linaro.org>, dri-devel@lists.freedesktop.org, Andrii Nakryiko <andrii@kernel.org>, Hans Verkuil <hverkuil@xs4all.nl>, linux-sctp@vger.kernel.org, "Md . Haris Iqbal" <haris.iqbal@ionos.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Christoph Hellwig <hch@lst.de>, Andy Gospodarek <andy@greyhouse.net>, Sergey Matyukevich <geomatsi@gmail.com>, Rohit Maheshwari <rohitm@chelsio.com>, Michael Ellerman <mpe@ellerman.id.au>, ceph-devel@vger.kernel.org, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Nilesh Javali <njavali@marvell.com>, Jean-Paul Roubelat <jpr@f6fbb.org>, Dick Kennedy <dick.kennedy@broadcom.com>, Jay Vosburgh <j.vosburgh@gmail.com>, Potnuri Bharat Teja <bharat@chelsio.com>, Vinay Kumar Yadav <vinay.yadav@chelsio.com>, linux-nfs@vg

On Thu, Oct 06, 2022 at 09:55:19AM -0300, Jason Gunthorpe wrote:
> On Thu, Oct 06, 2022 at 06:45:25AM -0600, Jason A. Donenfeld wrote:
> > On Wed, Oct 05, 2022 at 09:16:50PM -0700, Kees Cook wrote:
> > > On Wed, Oct 05, 2022 at 11:48:40PM +0200, Jason A. Donenfeld wrote:
> > > > Rather than incurring a division or requesting too many random bytes for
> > > > the given range, use the prandom_u32_max() function, which only takes
> > > > the minimum required bytes from the RNG and avoids divisions.
> > > 
> > > Yes please!
> > > 
> > > Since this is a treewide patch, it's helpful for (me at least) doing
> > > reviews to detail the mechanism of the transformation.
> > 
> > This is hand done. There were also various wrong seds done. And then I'd
> > edit the .diff manually, and then reapply it, as an iterative process.
> > No internet on the airplane, and oddly no spatch already on my laptop (I
> > think I had some Gentoo ocaml issues at some point and removed it?).
> > 
> > > e.g. I imagine this could be done with something like Coccinelle and
> > 
> > Feel free to check the work here by using Coccinelle if you're into
> > that.
> 
> Generally these series are a lot easier to review if it is structured
> as a patches doing all the unusual stuff that had to be by hand
> followed by an unmodified Coccinelle/sed/etc handling the simple
> stuff.
> 
> Especially stuff that is reworking the logic beyond simple
> substitution should be one patch per subsystem not rolled into a giant
> one patch conversion.
> 
> This makes the whole workflow better because the hand-done stuff can
> have a chance to flow through subsystem trees.

+1 to all arguments for the splitting.

I looked a bit into the code I have the interest to, but I won't spam people
with not-so-important questions / comments / tags, etc.

-- 
With Best Regards,
Andy Shevchenko
