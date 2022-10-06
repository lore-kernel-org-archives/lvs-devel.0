From: KP Singh <kpsingh@kernel.org>
Subject: Re: [PATCH v1 1/5] treewide: use prandom_u32_max() when
 possible
Date: Wed, 5 Oct 2022 21:22:17 -0700
Message-ID: <CACYkzJ6w6DitDk9uoEyyNeg+HmNHZx_tckJ_=EroqmT=CN3VBA@mail.gmail.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-2-Jason@zx2c4.com>
 <202210052035.A1020E3@keescook>
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
 bh=79D/+k/bRZXhGBAaempdgng3l68Zp7pbnLAWamJJEQU=; b=WGfYxA9/nmrVAss6aZJBbVO+jc
 7EFgdl51lzyuU+88/vDWeQ/yKL5PRdu2R9qVQ3whO9DttAtbbSn42q9byMizGU3ZBmPKp37aRQbEP
 iVMJOke/TyEOn3r8Z++PkMi0oLcs/eeD+XZioaNoED1t/u9OmCa5ewPWiUdmsW9eLZ0c=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=Content-Type:Cc:To:Subject:Message-ID:Date:From:In-Reply-To:References:
 MIME-Version:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=79D/+k/bRZXhGBAaempdgng3l68Zp7pbnLAWamJJEQU=; b=WT/5yR/BPSi1bA1AIqVBTOgs2g
 VOqERgCNjEzYRAj6xE96b+rOqswolwoaQvHTJmEhUwrTd3upB8bVo++nV3u3b7cZ0YzuUPNqK8y6X
 ztqSJeguIJQg8fG9idx55CkA59B+1LH+1VKXtgh3EtNPFfgG62MyTq/ZIEeBAeTtXppY=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1665030162;
 bh=HB4K7E86nsfwh8pjE5w4FJpZB/dXbKFz0OtI2RFCH+s=;
 h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
 b=U243XDpeQtdzP8OLbjBO8J34oe/T3rthPl2gsNKiT9xCqeUnUTBzfbdZR0oEbv8Mp
 lPUf13U9HZtldKkHu3hieQy1ooxgGr3je2Iyuov29SulKcYwRSQg8aT8ndxjKkrBm9
 yYZ1Uq8szapDDqaY77n9nTr7uQ/9X9WvUHPII0+TEdYCoMzEYZVnUy1SDg92Dq0uG2
 Ju8aaYT1AhIsd8qi8oF6wIzJ677pb+rbuaKAcxpTVzA4yhtL+83XMe6/9hKeCfKjTB
 mL7xYFl5DTW4GpUcX5w0ZJgJfMNDJ8SLOXyfnOzTwGam4VqrQ51ift8aGqYZ18csob
 aXa7zsdW2FHNQ==
In-Reply-To: <202210052035.A1020E3@keescook>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Lunn <andrew@lunn.ch>, "Darrick J . Wong" <djwong@kernel.org>, Ulf Hansson <ulf.hansson@linaro.org>, dri-devel@lists.freedesktop.org, Andrii Nakryiko <andrii@kernel.org>, Hans Verkuil <hverkuil@xs4all.nl>, linux-sctp@vger.kernel.org, "Md . Haris Iqbal" <haris.iqbal@ionos.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Christoph Hellwig <hch@lst.de>, Andy Gospodarek <andy@greyhouse.net>, Sergey Matyukevich <geomatsi@gmail.com>, Rohit Maheshwari <rohitm@chelsio.com>, Michael Ellerman <mpe@ellerman.id.au>, ceph-devel@vger.kernel.org, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Nilesh Javali <njavali@marvell.com>, Jean-Paul Roubelat <jpr@f6fbb.org>, Dick Kennedy <dick.kennedy@broadcom.com>, Jay Vosburgh <j.vosburgh@gmail.com>, Potnuri Bharat Teja <bharat@chelsio.com>, Vinay Kumar Yadav <vinay.yadav@chelsio.com>, linux-nfs@vg

On Wed, Oct 5, 2022 at 9:16 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Oct 05, 2022 at 11:48:40PM +0200, Jason A. Donenfeld wrote:
> > Rather than incurring a division or requesting too many random bytes for
> > the given range, use the prandom_u32_max() function, which only takes
> > the minimum required bytes from the RNG and avoids divisions.
>
> Yes please!
>
> Since this is a treewide patch, it's helpful for (me at least) doing
> reviews to detail the mechanism of the transformation.
>
> e.g. I imagine this could be done with something like Coccinelle and
>
> @no_modulo@
> expression E;
> @@
>
> -       (prandom_u32() % (E))
> +       prandom_u32_max(E)
>
> > diff --git a/drivers/mtd/ubi/debug.h b/drivers/mtd/ubi/debug.h
> > index 118248a5d7d4..4236c799a47c 100644
> > --- a/drivers/mtd/ubi/debug.h
> > +++ b/drivers/mtd/ubi/debug.h
> > @@ -73,7 +73,7 @@ static inline int ubi_dbg_is_bgt_disabled(const struct ubi_device *ubi)
> >  static inline int ubi_dbg_is_bitflip(const struct ubi_device *ubi)
> >  {
> >       if (ubi->dbg.emulate_bitflips)
> > -             return !(prandom_u32() % 200);
> > +             return !(prandom_u32_max(200));
> >       return 0;
> >  }
> >
>
> Because some looks automated (why the parens?)
>
> > @@ -393,14 +387,11 @@ static struct test_driver {
> >
> >  static void shuffle_array(int *arr, int n)
> >  {
> > -     unsigned int rnd;
> >       int i, j;
> >
> >       for (i = n - 1; i > 0; i--)  {
> > -             rnd = prandom_u32();
> > -
> >               /* Cut the range. */
> > -             j = rnd % i;
> > +             j = prandom_u32_max(i);
> >
> >               /* Swap indexes. */
> >               swap(arr[i], arr[j]);
>
> And some by hand. :)
>
> Reviewed-by: Kees Cook <keescook@chromium.org>

Thanks!

Reviewed-by: KP Singh <kpsingh@kernel.org>


>
> --
> Kees Cook
