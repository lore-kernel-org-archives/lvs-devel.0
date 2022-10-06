From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v1 4/5] treewide: use get_random_bytes when
	possible
Date: Wed, 5 Oct 2022 21:48:09 -0700
Message-ID: <202210052148.AA3C7BB@keescook>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-5-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org E18F083E0E
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org EB0DB83DEF
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 748F54032B
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 346BF40301
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date;
 bh=Zga/kwguXOa9tZGzF2X+ZLpnzxGRszRa7j7kheBbr2g=;
 b=VDYXzBjTmlsVIl+Y4iF0uyvrgTLR7zDCDitOOtRhnnkCI+cj7BOAV+jXORmkdJC8NR
 kLVeoGGmNjWIzbs7ngaNL2av6vzDETZ5xNshsjkA6+Ddrv+XZy7wZSPrRI2h/WYQMveo
 FOjR6IXNtLQ2MzWVWNTzoDYr9QH87X51UPqiU=
Content-Disposition: inline
In-Reply-To: <20221005214844.2699-5-Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
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

On Wed, Oct 05, 2022 at 11:48:43PM +0200, Jason A. Donenfeld wrote:
> The prandom_bytes() function has been a deprecated inline wrapper around
> get_random_bytes() for several releases now, and compiles down to the
> exact same code. Replace the deprecated wrapper with a direct call to
> the real function.
> 
> Signed-off-by: Jason A. Donenfeld <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>

Global search/replace matches. :)

Reviewed-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

-- 
Kees Cook
