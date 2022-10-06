From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v1 1/5] treewide: use prandom_u32_max() when
	possible
Date: Wed, 5 Oct 2022 21:16:50 -0700
Message-ID: <202210052035.A1020E3@keescook>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-2-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 8A8EE409A5
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 5E49840147
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org BCACE81AA7
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org 52A9881763
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date;
 bh=WbAjddv7dJAWgX74vxMdFtfHq8KnIvmUd6IHydPVZWw=;
 b=WgCBVOxTCY3r6hnjb6DkPXMWKhTpJd2tJ8grQVy4FqddmqNDeeFgajag3lajOwT2v4
 a87IfTIAA5TCPftGBNiy4cY7xnOoxUEfMiQjvrPT/rt/xjKxauu3MOYhjJEXssFW35Ee
 /z+9ItQjm7QhlvSxza54MmNIb/ZuYs/f028rM=
Content-Disposition: inline
In-Reply-To: <20221005214844.2699-2-Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
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
To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, "Darrick J . Wong" <djwong-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Andrii Nakryiko <andrii-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Md . Haris Iqbal" <haris.iqbal-vEVw2sk9H7kAvxtiuMwx3w@public.gmane.org>, Miquel Raynal <miquel.raynal-LDxbnhwyfcJBDgjK7y7TUQ@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, Sergey Matyukevich <geomatsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rohit Maheshwari <rohitm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christophe Leroy <christophe.leroy-2tlSp11Fh4xulxpn9UvDqw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Nilesh Javali <njavali-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Jean-Paul Roubelat <jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>, Dick Kennedy <dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Jay Vosburgh <j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Potnuri Bharat Teja <bharat-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Vinay Kumar Yadav <vinay.yadav-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vg

On Wed, Oct 05, 2022 at 11:48:40PM +0200, Jason A. Donenfeld wrote:
> Rather than incurring a division or requesting too many random bytes for
> the given range, use the prandom_u32_max() function, which only takes
> the minimum required bytes from the RNG and avoids divisions.

Yes please!

Since this is a treewide patch, it's helpful for (me at least) doing
reviews to detail the mechanism of the transformation.

e.g. I imagine this could be done with something like Coccinelle and

@no_modulo@
expression E;
@@

-	(prandom_u32() % (E))
+	prandom_u32_max(E)

> diff --git a/drivers/mtd/ubi/debug.h b/drivers/mtd/ubi/debug.h
> index 118248a5d7d4..4236c799a47c 100644
> --- a/drivers/mtd/ubi/debug.h
> +++ b/drivers/mtd/ubi/debug.h
> @@ -73,7 +73,7 @@ static inline int ubi_dbg_is_bgt_disabled(const struct ubi_device *ubi)
>  static inline int ubi_dbg_is_bitflip(const struct ubi_device *ubi)
>  {
>  	if (ubi->dbg.emulate_bitflips)
> -		return !(prandom_u32() % 200);
> +		return !(prandom_u32_max(200));
>  	return 0;
>  }
>  

Because some looks automated (why the parens?)

> @@ -393,14 +387,11 @@ static struct test_driver {
>  
>  static void shuffle_array(int *arr, int n)
>  {
> -	unsigned int rnd;
>  	int i, j;
>  
>  	for (i = n - 1; i > 0; i--)  {
> -		rnd = prandom_u32();
> -
>  		/* Cut the range. */
> -		j = rnd % i;
> +		j = prandom_u32_max(i);
>  
>  		/* Swap indexes. */
>  		swap(arr[i], arr[j]);

And some by hand. :)

Reviewed-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

-- 
Kees Cook
