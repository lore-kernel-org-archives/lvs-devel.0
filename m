From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when possible
Date: Thu, 6 Oct 2022 10:15:35 -0300
Message-ID: <Yz7U99PPl8uHCLFY@ziepe.ca>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com>
 <Yz7OdfKZeGkpZSKb@ziepe.ca>
 <CAHmME9r_vNRFFjUvqx8QkBddg_kQU=FMgpk9TqOVZdvX6zXHNg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-raid-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date;
        bh=GSOPunDdTF0UIVvBpION9xBpexDiGo+rjOxipFbXtOA=;
        b=j4TXfdYhCC5IuPEKT7c142DGOyyUICiYEJ2rQ5pM4q0yiZx4WA0kHStxgeCysxKdIn
         TuxQmiKuGnCh2iLv5lCSAeVvdfZCgr0gslAO6C/wmbiJpJE+HGv9p0BlGAp2YHTd7MAZ
         JFShEKjZddNRI3EB69zxWrjNCIn5FEtT938q5Kh600byBOTgEAyr3Cw5BxKLykg6qGKZ
         putHsZDuOr6KOj1BUasiDhf52tRH/Ed62HmMrAEpEsYDeTWjqgqViGX5p251folDWhG6
         /9qz6hzxVHLZMa8vddlM+hc6XFLs5D7qWuuoVr7OgpiuiN/JdE0keFKPOZzvhwuMVbjX
         g/wA==
Content-Disposition: inline
In-Reply-To: <CAHmME9r_vNRFFjUvqx8QkBddg_kQU=FMgpk9TqOVZdvX6zXHNg@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: linux-kernel@vger.kernel.org, brcm80211-dev-list.pdl@broadcom.com, cake@lists.bufferbloat.net, ceph-devel@vger.kernel.org, coreteam@netfilter.org, dccp@vger.kernel.org, dev@openvswitch.org, dmaengine@vger.kernel.org, drbd-dev@lists.linbit.com, dri-devel@lists.freedesktop.org, kasan-dev@googlegroups.com, linux-actions@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-hams@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-mmc@vger.kernel.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, linux-nvme@lists.infradead.org, linux-

On Thu, Oct 06, 2022 at 07:05:48AM -0600, Jason A. Donenfeld wrote:

> > > diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> > > index fd9d7f2c4d64..a605cf66b83e 100644
> > > --- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> > > +++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> > > @@ -465,7 +465,7 @@ static int ipoib_cm_req_handler(struct ib_cm_id *cm_id,
> > >               goto err_qp;
> > >       }
> > >
> > > -     psn = prandom_u32() & 0xffffff;
> > > +     psn = get_random_u32() & 0xffffff;
> >
> >  prandom_max(0xffffff + 1)
> 
> That'd work, but again it's not more clear. Authors here are going for
> a 24-bit number, and masking seems like a clear way to express that.

vs just asking directly for a 24 bit number?

Jason
