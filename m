From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: allow connection reuse for unconfirmed
 conntrack
Date: Thu, 2 Jul 2020 11:18:29 +0200
Message-ID: <20200702091829.GB6691@vergenet.net>
References: <20200701151719.4751-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200701151719.4751-1-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, YangYuxi <yx.atom1@gmail.com>

On Wed, Jul 01, 2020 at 06:17:19PM +0300, Julian Anastasov wrote:
> YangYuxi is reporting that connection reuse
> is causing one-second delay when SYN hits
> existing connection in TIME_WAIT state.
> Such delay was added to give time to expire
> both the IPVS connection and the corresponding
> conntrack. This was considered a rare case
> at that time but it is causing problem for
> some environments such as Kubernetes.
>=20
> As nf_conntrack_tcp_packet() can decide to
> release the conntrack in TIME_WAIT state and
> to replace it with a fresh NEW conntrack, we
> can use this to allow rescheduling just by
> tuning our check: if the conntrack is
> confirmed we can not schedule it to different
> real server and the one-second delay still
> applies but if new conntrack was created,
> we are free to select new real server without
> any delays.
>=20
> YangYuxi lists some of the problem reports:
>=20
> - One second connection delay in masquerading mode:
> https://marc.info/?t=3D151683118100004&r=3D1&w=3D2
>=20
> - IPVS low throughput=C2=A0#70747
> https://github.com/kubernetes/kubernetes/issues/70747
>=20
> - Apache Bench can fill up ipvs service proxy in seconds #544
> https://github.com/cloudnativelabs/kube-router/issues/544
>=20
> - Additional 1s latency in `host -> service IP -> pod`
> https://github.com/kubernetes/kubernetes/issues/90854
>=20
> Fixes: f719e3754ee2 ("ipvs: drop first packet to redirect conntrack")
> Co-developed-by: YangYuxi <yx.atom1@gmail.com>
> Signed-off-by: YangYuxi <yx.atom1@gmail.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, this looks good to me.

Reviewed-by: Simon Horman <horms@verge.net.au>

Pablo, could you consider applying this to nf-next?
