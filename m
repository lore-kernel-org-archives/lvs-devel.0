From: "Jason A. Donenfeld via dev" <ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Subject: Re: [PATCH v1 1/5] treewide: use prandom_u32_max() when
	possible
Date: Thu, 6 Oct 2022 06:45:25 -0600
Message-ID: <Yz7N5WsqmKiUl+6b@zx2c4.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-2-Jason@zx2c4.com>
 <202210052035.A1020E3@keescook>
Reply-To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 27FA761050
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 94566605A9
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 16E8440C4C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org BF84640223
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
 t=1665060337;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=8dWFI8h4OMBAtrqSOGO78rNNmSB/3Qreg0w0Og/94qc=;
 b=gqKJ5uKA335nUt4dHqz8iF9PLBDcDgx3n0YhiOxMrlk3oPDvs/7yiBJIDKV/E4nv62pdqe
 sPWU3H5aG76qM2evnoA3/Ys8c2HrO6GXFQDfmwl/KqnyJgMuSbwIQZf5GAnNUvK/lVQDpw
 cqr/cVirflho361qsz5SQunwSlNAMYo=
Content-Disposition: inline
In-Reply-To: <202210052035.A1020E3@keescook>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
 <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
 <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, "Darrick J . Wong" <djwong-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Andrii Nakryiko <andrii-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Md . Haris Iqbal" <haris.iqbal-vEVw2sk9H7kAvxtiuMwx3w@public.gmane.org>, Miquel Raynal <miquel.raynal-LDxbnhwyfcJBDgjK7y7TUQ@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, Sergey Matyukevich <geomatsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rohit Maheshwari <rohitm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christophe Leroy <christophe.leroy-2tlSp11Fh4xulxpn9UvDqw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Nilesh Javali <njavali-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Jean-Paul Roubelat <jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>, Dick Kennedy <dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Jay Vosburgh <j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Potnuri Bharat Teja <bharat-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Vinay Kumar Yadav <vinay.yadav-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vg

Hi Kees,

On Wed, Oct 05, 2022 at 09:16:50PM -0700, Kees Cook wrote:
> On Wed, Oct 05, 2022 at 11:48:40PM +0200, Jason A. Donenfeld wrote:
> > Rather than incurring a division or requesting too many random bytes for
> > the given range, use the prandom_u32_max() function, which only takes
> > the minimum required bytes from the RNG and avoids divisions.
> 
> Yes please!
> 
> Since this is a treewide patch, it's helpful for (me at least) doing
> reviews to detail the mechanism of the transformation.

This is hand done. There were also various wrong seds done. And then I'd
edit the .diff manually, and then reapply it, as an iterative process.
No internet on the airplane, and oddly no spatch already on my laptop (I
think I had some Gentoo ocaml issues at some point and removed it?).

> e.g. I imagine this could be done with something like Coccinelle and

Feel free to check the work here by using Coccinelle if you're into
that.

> >  static inline int ubi_dbg_is_bitflip(const struct ubi_device *ubi)
> >  {
> >  	if (ubi->dbg.emulate_bitflips)
> > -		return !(prandom_u32() % 200);
> > +		return !(prandom_u32_max(200));
> >  	return 0;
> >  }
> >  
> 
> Because some looks automated (why the parens?)

I saw this before going out and thought I'd fixed it but I guess I sent
the wrong one.

Jason
