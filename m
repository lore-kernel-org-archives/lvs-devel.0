From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when possible
Date: Thu, 6 Oct 2022 16:20:31 +0300
Message-ID: <Yz7WHyD+teLOh2ho@smile.fi.intel.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com>
 <Yz7OdfKZeGkpZSKb@ziepe.ca>
 <CAHmME9r_vNRFFjUvqx8QkBddg_kQU=FMgpk9TqOVZdvX6zXHNg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-block-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1665062447; x=1696598447;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=EU0abpI6YFdk3YA4KGgLZ9e2cnqNyTF/1r17KmA6WbU=;
  b=H/rXg2onBw8kdQTJR9j91bg7GaQ9NTLI4VQaO5RUMKhgyGVdTsqC0ihZ
   ZFrzupyxaktvnWl0/oAO1N0j+d7VdJ7vhM5jhQno6ZKD98/lmLTbJHLEk
   YdnjF2+yZPR82O204zlslKkxKat4YQqK1Imt18zDrXqo1ccS1JJsVSyxk
   MRKlQcD0RpszRcaGv0aLNg8NB07bkMRbNN5u6y9NvDUd9Pep7UTxlCSgc
   gMlNjOL77ikXzd/PJ+sKmxYh/x98yvYK62uMdNxBx1YoiL7Kpv6EnctwN
   rw/6E45iagBLiy4ub27Y6WReJAotEZtIYsSDo2cskapKSLTwKhAf1RYEB
   A==;
Content-Disposition: inline
In-Reply-To: <CAHmME9r_vNRFFjUvqx8QkBddg_kQU=FMgpk9TqOVZdvX6zXHNg@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-kernel@vger.kernel.org, brcm80211-dev-list.pdl@broadcom.com, cake@lists.bufferbloat.net, ceph-devel@vger.kernel.org, coreteam@netfilter.org, dccp@vger.kernel.org, dev@openvswitch.org, dmaengine@vger.kernel.org, drbd-dev@lists.linbit.com, dri-devel@lists.freedesktop.org, kasan-dev@googlegroups.com, linux-actions@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org, linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-hams@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-mmc@vger.kernel.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org

On Thu, Oct 06, 2022 at 07:05:48AM -0600, Jason A. Donenfeld wrote:
> On Thu, Oct 6, 2022 at 6:47 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Wed, Oct 05, 2022 at 11:48:42PM +0200, Jason A. Donenfeld wrote:

...

> > > -     u32 isn = (prandom_u32() & ~7UL) - 1;
> > > +     u32 isn = (get_random_u32() & ~7UL) - 1;
> >
> > Maybe this wants to be written as
> >
> > (prandom_max(U32_MAX >> 7) << 7) | 7

> > ?
> 
> Holy smokes. Yea I guess maybe? It doesn't exactly gain anything or
> make the code clearer though, and is a little bit more magical than
> I'd like on a first pass.

Shouldn't the two first 7s to be 3s?

...

> > > -     psn = prandom_u32() & 0xffffff;
> > > +     psn = get_random_u32() & 0xffffff;
> >
> >  prandom_max(0xffffff + 1)
> 
> That'd work, but again it's not more clear. Authors here are going for
> a 24-bit number, and masking seems like a clear way to express that.

We have some 24-bit APIs (and 48-bit) already in kernel, why not to have
get_random_u24() ?


-- 
With Best Regards,
Andy Shevchenko


