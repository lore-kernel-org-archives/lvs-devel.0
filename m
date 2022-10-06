From: "Jason A. Donenfeld via Linux-f2fs-devel"
 <linux-f2fs-devel@lists.sourceforge.net>
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when
 possible
Date: Thu, 6 Oct 2022 07:07:24 -0600
Message-ID: <CAHmME9r2u86Ga1UL_yD6x44OX84UJbRQyfhhDjF1daXyaYsbEw@mail.gmail.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com>
 <20221006084331.4bdktc2zlvbaszym@quack3> <Yz7LCyIAHC6l5mG9@zx2c4.com>
 <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
Reply-To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=sourceforge.net; s=x; h=Content-Type:Cc:To:Subject:Message-ID:Date:From:
 In-Reply-To:References:MIME-Version:Sender:Reply-To:Content-Transfer-Encoding
 :Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
 Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:
 List-Subscribe:List-Post:List-Owner:List-Archive;
 bh=Ot8N/NmxnMNw5DlaW1IKdsMRDrHlZI2nii4+1SScqOw=; b=IOhlBWwf7zWJjqmjHoMSBfvM2a
 A8Yj49XSLy3M0w3sxMoRwAeL7FV/neTNoiI4CDUmmYJ8LhSJCfHaBEUAfwucqxmFH1yEzAhoFwE8H
 jVpgNcMtwQhELM48VUv6Tn3rqY19VdLYI69Xeu7ZFEl0o2Bh1i+R7tOIEYmRGWeibdSs=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=Content-Type:Cc:To:Subject:Message-ID:Date:From:In-Reply-To:References:
 MIME-Version:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=Ot8N/NmxnMNw5DlaW1IKdsMRDrHlZI2nii4+1SScqOw=; b=KeQtqjaJbaT59AGvWkJ4IgDnpn
 hRidkQcuUKTIrXyOZ3CAmJoGECNT4JJegc5yufOr92gnZyeh2Sez8/f2FfveB+HgFHLR1Cb4Mxk4I
 H7MqH7J1EgQatsaFOubLSbBqPImWuHvyWDxoa3SH/IYwvJrux1R+Q49tAjwN+NjF90PE=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
 t=1665061678;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=Ot8N/NmxnMNw5DlaW1IKdsMRDrHlZI2nii4+1SScqOw=;
 b=G0taENf+FZwhBnRgOp/KbrTv3h4C/YEIUyGMekXqM3ZgvHwYrc/uQ1icM6fzRP/J7CEv9F
 zdHPf6c8U+Yxv0KNDFcjYxAkhXO5YGDmAtJi9ZD1kOkM0zr66pFbit9FpeNZ4gVbMyRruM
 1bZ8ZZSBeTYhGE6ZI8w583EAN/TTVNE=
In-Reply-To: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Andrew Lunn <andrew@lunn.ch>, "Darrick J . Wong" <djwong@kernel.org>, linux-block@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, dri-devel@lists.freedesktop.org, Andrii Nakryiko <andrii@kernel.org>, Hans Verkuil <hverkuil@xs4all.nl>, linux-sctp@vger.kernel.org, "Md . Haris Iqbal" <haris.iqbal@ionos.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Christoph Hellwig <hch@lst.de>, Andy Gospodarek <andy@greyhouse.net>, Sergey Matyukevich <geomatsi@gmail.com>, Rohit Maheshwari <rohitm@chelsio.com>, Michael Ellerman <mpe@ellerman.id.au>, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Nilesh Javali <njavali@marvell.com>, Jean-Paul Roubelat <jpr@f6fbb.org>, Dan Williams <dan.j.williams@intel.com>, Dick Kennedy <dick.kennedy@broadcom.com>, Jay Vosburgh <j.vosburgh@gmail.com>, Potnuri Bharat Teja <bharat@chelsio.com>

On Thu, Oct 6, 2022 at 7:01 AM Andy Shevchenko
<andriy.shevchenko@linux.intel.com> wrote:
>
> On Thu, Oct 06, 2022 at 06:33:15AM -0600, Jason A. Donenfeld wrote:
> > On Thu, Oct 06, 2022 at 10:43:31AM +0200, Jan Kara wrote:
>
> ...
>
> > > The code here is effectively doing the
> > >
> > >     parent_group = prandom_u32_max(ngroups);
> > >
> > > Similarly here we can use prandom_u32_max(ngroups) like:
> > >
> > >             if (qstr) {
> > >                     ...
> > >                     parent_group = hinfo.hash % ngroups;
> > >             } else
> > >                     parent_group = prandom_u32_max(ngroups);
> >
> > Nice catch. I'll move these to patch #1.
>
> I believe coccinelle is able to handle this kind of code as well

I'd be extremely surprised. The details were kind of non obvious. I
just spent a decent amount of time manually checking those blocks, to
make sure we didn't wind up with different behavior, given the
variable reuse.

Jason
