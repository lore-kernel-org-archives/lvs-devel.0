From: "Jason A. Donenfeld via dev" <ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Subject: Re: [PATCH v1 2/5] treewide: use get_random_{u8,
	u16}() when possible
Date: Thu, 6 Oct 2022 06:28:26 -0600
Message-ID: <Yz7J6j3cXDLK7O6A@zx2c4.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-3-Jason@zx2c4.com>
 <202210052126.B34A2C62@keescook>
Reply-To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 3DA5D6102C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 5DCC160E2A
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org DF27D60E4C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org BD8A660E2A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
 t=1665059318;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=5CT4nH/m4137cke6a9HxB/7vcArAWSQRa4usYkfKNrg=;
 b=OS8t32IGu3oCxKhFrKsoTlJdA0ilidFXzfDav1WbEMtetkdGq8zG44OTpAoolbKblRE28x
 JavSPZ213Zn0QlCC7qiV7HVuoj014/Af3MYIJXK6V6JzJ66H365IrRZBlUnLH9HyqJISSh
 i7WOLg4+btGeRh3RwCHT+vvVoWgXHqc=
Content-Disposition: inline
In-Reply-To: <202210052126.B34A2C62@keescook>
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

On Wed, Oct 05, 2022 at 09:38:02PM -0700, Kees Cook wrote:
> > diff --git a/lib/test_vmalloc.c b/lib/test_vmalloc.c
> > index 56ffaa8dd3f6..0131ed2cd1bd 100644
> > --- a/lib/test_vmalloc.c
> > +++ b/lib/test_vmalloc.c
> > @@ -80,7 +80,7 @@ static int random_size_align_alloc_test(void)
> >  	int i;
> >  
> >  	for (i = 0; i < test_loop_count; i++) {
> > -		rnd = prandom_u32();
> > +		rnd = get_random_u8();
> >  
> >  		/*
> >  		 * Maximum 1024 pages, if PAGE_SIZE is 4096.
> 
> This wasn't obvious either, but it looks like it's because it never
> consumes more than u8?

Right. The only uses of that are %23 and %10 later on down.

Jason
