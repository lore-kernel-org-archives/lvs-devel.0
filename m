From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when possible
Date: Wed, 12 Oct 2022 12:16:53 -0700
Message-ID: <f8ad3ba44d28dec1a5f7626b82c5e9c2aeefa729.camel@perches.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
	 <20221005214844.2699-4-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane-mx.org@lists.ozlabs.org>
In-Reply-To: <20221005214844.2699-4-Jason@zx2c4.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane-mx.org@lists.ozlabs.org
Sender: "Linuxppc-dev" <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane-mx.org@lists.ozlabs.org>
Content-Type: text/plain; charset="us-ascii"
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-kernel@vger.kernel.org
Cc: linux-fbdev@vger.kernel.org, linux-doc@vger.kernel.org, linux-wireless@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-sctp@vger.kernel.org, target-devel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-stm32@st-md-mailman.stormreply.com, drbd-dev@lists.linbit.com, dev@openvswitch.org, rds-devel@oss.oracle.com, linux-scsi@vger.kernel.org, dccp@vger.kernel.org, linux-rdma@vger.kernel.org, kasan-dev@googlegroups.com, lvs-devel@vger.kernel.org, SHA-cyfmac-dev-list@infineon.com, coreteam@netfilter.org, tipc-discussion@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-media@vger.kernel.org, linux-actions@lists.infradead.org, linux-nfs@vger.kernel.org, linux-block@vger.kernel.org, dmaengine@vger.kernel.org, linux-nvme@lists.infradead.org, linux-hams@vg, er.kernel.org, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, cake@lists.buffer

On Wed, 2022-10-05 at 23:48 +0200, Jason A. Donenfeld wrote:
> The prandom_u32() function has been a deprecated inline wrapper around
> get_random_u32() for several releases now, and compiles down to the
> exact same code. Replace the deprecated wrapper with a direct call to
> the real function.
[]
> diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxg=
b4/cm.c
[]
> @@ -734,7 +734,7 @@ static int send_connect(struct c4iw_ep *ep)
>  				   &ep->com.remote_addr;
>  	int ret;
>  	enum chip_type adapter_type =3D ep->com.dev->rdev.lldi.adapter_type;
> -	u32 isn =3D (prandom_u32() & ~7UL) - 1;
> +	u32 isn =3D (get_random_u32() & ~7UL) - 1;

trivia:

There are somewhat odd size mismatches here.

I had to think a tiny bit if random() returned a value from 0 to 7
and was promoted to a 64 bit value then truncated to 32 bit.

Perhaps these would be clearer as ~7U and not ~7UL

>  	struct net_device *netdev;
>  	u64 params;
> =20
> @@ -2469,7 +2469,7 @@ static int accept_cr(struct c4iw_ep *ep, struct sk_=
buff *skb,
>  	}
> =20
>  	if (!is_t4(adapter_type)) {
> -		u32 isn =3D (prandom_u32() & ~7UL) - 1;
> +		u32 isn =3D (get_random_u32() & ~7UL) - 1;

etc...

drivers/infiniband/hw/cxgb4/cm.c:	u32 isn =3D (prandom_u32() & ~7UL) - 1;
drivers/infiniband/hw/cxgb4/cm.c:		u32 isn =3D (prandom_u32() & ~7UL) - 1;
drivers/net/ethernet/chelsio/inline_crypto/chtls/chtls_cm.c:	rpl5->iss =3D =
cpu_to_be32((prandom_u32() & ~7UL) - 1);
drivers/scsi/cxgbi/cxgb4i/cxgb4i.c:		u32 isn =3D (prandom_u32() & ~7UL) - 1=
;
drivers/scsi/cxgbi/cxgb4i/cxgb4i.c:		u32 isn =3D (prandom_u32() & ~7UL) - 1=
;
drivers/target/iscsi/cxgbit/cxgbit_cm.c:	rpl5->iss =3D cpu_to_be32((prandom=
_u32() & ~7UL) - 1);

