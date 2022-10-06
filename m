From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v1 1/5] treewide: use prandom_u32_max() when
 possible
Date: Thu, 6 Oct 2022 09:55:19 -0300
Message-ID: <Yz7QN3cbKABexzoB@ziepe.ca>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-2-Jason@zx2c4.com>
 <202210052035.A1020E3@keescook> <Yz7N5WsqmKiUl+6b@zx2c4.com>
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
 bh=Tn+sqw4/yCgRf+qJVvhcwv0+F43hCZc6SWcnJkISat8=; b=fEbI6BRJCnpM2HP0RywE7I+dGb
 KjuznqExfu8VpZ01RiajPG5ytL5vS7XJ0MjC64OWpYf47nwiQa9HpISoKpUDcTzOZfcR3DnMh1dyw
 5nQAQxb+fSRx6Q93V6O6/hHB8adIqvb9unO5KZmjQqrmfEMzp+UXFdpB69bSvGl4ypp8=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=In-Reply-To:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To
 :From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=Tn+sqw4/yCgRf+qJVvhcwv0+F43hCZc6SWcnJkISat8=; b=h3Ol4Ws0ked0Q4L4fR5PQZD0uT
 2bmpPekXWeH8N04MhpgXMRBw2fExMmmeq+MEsZJSeyh6ok50zsjkGiWEAzavl9tfwxnK+yA2sLJrg
 uElYWELP5QyFTnU2lU2B/b+U2kc8gqK8pZXr+g3ELMpCLLbLl7UCGT0Y7FOZnvJ8w7Yc=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ziepe.ca; s=google;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date;
 bh=Tn+sqw4/yCgRf+qJVvhcwv0+F43hCZc6SWcnJkISat8=;
 b=fRB9gEBBoKCu8DvmgrE5jsT6iQulOo1Wq07FJ4Am2X2qPDPghUCGIGqelzq6LtOhav
 Q3ch36mdptG+4DDNPe7LXRCCqOYd+swKkjl9ojx7+DaHms2Ps8ZhIK036brGZcmpW/UJ
 S9x30Eavu5Tk31fMMwn3nSkBSD8/Tghiz9zSBMFnjKzScWXJY3JUjmENpKuorArjMkg6
 rQNb/QJQWH453Lx7yVByUvRWnmkZMXKg6u7yi6uAEcrODzXacr1TQUVtDk0Ogg7EUu2A
 PX8hy4jr/Qi4/DXYjmQMgPSxylmXfgjJuV6SX/HkBNz1t9W02fkJr+gOlTe0wIrhjOHu
 XfWA==
Content-Disposition: inline
In-Reply-To: <Yz7N5WsqmKiUl+6b@zx2c4.com>
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

On Thu, Oct 06, 2022 at 06:45:25AM -0600, Jason A. Donenfeld wrote:
> Hi Kees,
> 
> On Wed, Oct 05, 2022 at 09:16:50PM -0700, Kees Cook wrote:
> > On Wed, Oct 05, 2022 at 11:48:40PM +0200, Jason A. Donenfeld wrote:
> > > Rather than incurring a division or requesting too many random bytes for
> > > the given range, use the prandom_u32_max() function, which only takes
> > > the minimum required bytes from the RNG and avoids divisions.
> > 
> > Yes please!
> > 
> > Since this is a treewide patch, it's helpful for (me at least) doing
> > reviews to detail the mechanism of the transformation.
> 
> This is hand done. There were also various wrong seds done. And then I'd
> edit the .diff manually, and then reapply it, as an iterative process.
> No internet on the airplane, and oddly no spatch already on my laptop (I
> think I had some Gentoo ocaml issues at some point and removed it?).
> 
> > e.g. I imagine this could be done with something like Coccinelle and
> 
> Feel free to check the work here by using Coccinelle if you're into
> that.

Generally these series are a lot easier to review if it is structured
as a patches doing all the unusual stuff that had to be by hand
followed by an unmodified Coccinelle/sed/etc handling the simple
stuff.

Especially stuff that is reworking the logic beyond simple
substitution should be one patch per subsystem not rolled into a giant
one patch conversion.

This makes the whole workflow better because the hand-done stuff can
have a chance to flow through subsystem trees.

Thanks,
Jason
