From: "Jason A. Donenfeld via dev" <ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when
	possible
Date: Thu, 6 Oct 2022 07:05:48 -0600
Message-ID: <CAHmME9r_vNRFFjUvqx8QkBddg_kQU=FMgpk9TqOVZdvX6zXHNg@mail.gmail.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com> <Yz7OdfKZeGkpZSKb@ziepe.ca>
Reply-To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 900CC40C4C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 7CB1D40223
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 4355240C2B
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 218DA40223
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
 t=1665061581;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=pA8UwcaEH1EIaWBd+j+3kMQvSGVLEaIn/zvGprOy4bY=;
 b=olBPwSHhemo7SqJZrD/ohuL/GJOH6P8oRtQiCgFrh6JtzQ3eHzKBrfOp5rqZEljamNPYtM
 d3tDiNWyJdIguKFPG/fKCfGFr/l1S51a3Y0tUyLoghfcpwMwwLwwWXTvh90Uc/SDuFMJPq
 nWucyfXmWaSqVQulBeew44uvASWmLeg=
In-Reply-To: <Yz7OdfKZeGkpZSKb-uk2M96/98Pc@public.gmane.org>
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
To: Jason Gunthorpe <jgg-uk2M96/98Pc@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, "Darrick J . Wong" <djwong-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Andrii Nakryiko <andrii-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Md . Haris Iqbal" <haris.iqbal-vEVw2sk9H7kAvxtiuMwx3w@public.gmane.org>, Miquel Raynal <miquel.raynal-LDxbnhwyfcJBDgjK7y7TUQ@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, Sergey Matyukevich <geomatsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rohit Maheshwari <rohitm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christophe Leroy <christophe.leroy-2tlSp11Fh4xulxpn9UvDqw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Nilesh Javali <njavali-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Jean-Paul Roubelat <jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>, Dick Kennedy <dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Jay Vosburgh <j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Potnuri Bharat Teja <bharat-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Vinay Kumar Yadav <vinay.yadav-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vg

On Thu, Oct 6, 2022 at 6:47 AM Jason Gunthorpe <jgg-uk2M96/98Pc@public.gmane.org> wrote:
>
> On Wed, Oct 05, 2022 at 11:48:42PM +0200, Jason A. Donenfeld wrote:
>
> > index 14392c942f49..499a425a3379 100644
> > --- a/drivers/infiniband/hw/cxgb4/cm.c
> > +++ b/drivers/infiniband/hw/cxgb4/cm.c
> > @@ -734,7 +734,7 @@ static int send_connect(struct c4iw_ep *ep)
> >                                  &ep->com.remote_addr;
> >       int ret;
> >       enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
> > -     u32 isn = (prandom_u32() & ~7UL) - 1;
> > +     u32 isn = (get_random_u32() & ~7UL) - 1;
>
> Maybe this wants to be written as
>
> (prandom_max(U32_MAX >> 7) << 7) | 7
>
> ?

Holy smokes. Yea I guess maybe? It doesn't exactly gain anything or
make the code clearer though, and is a little bit more magical than
I'd like on a first pass.

>
> > diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> > index fd9d7f2c4d64..a605cf66b83e 100644
> > --- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> > +++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
> > @@ -465,7 +465,7 @@ static int ipoib_cm_req_handler(struct ib_cm_id *cm_id,
> >               goto err_qp;
> >       }
> >
> > -     psn = prandom_u32() & 0xffffff;
> > +     psn = get_random_u32() & 0xffffff;
>
>  prandom_max(0xffffff + 1)

That'd work, but again it's not more clear. Authors here are going for
a 24-bit number, and masking seems like a clear way to express that.

Jason
