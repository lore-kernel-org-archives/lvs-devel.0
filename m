From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH nf-next 1/2] ipvs: Remove possibly unused variable from
 ip_vs_out
Date: Wed, 7 Oct 2015 16:58:47 +0300
Message-ID: <56152517.6020807@cogentembedded.com>
References: <1444195403-4288-1-git-send-email-horms@verge.net.au>
 <1444195403-4288-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1444195403-4288-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"; format="flowed"
To: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsa@cumulusnetworks.com>

Hello.

On 10/7/2015 8:23 AM, Simon Horman wrote:

> From: David Ahern <dsa@cumulusnetworks.com>
>
> Eric's net namespace changes in 1b75097dd7a26 leaves net unreferenced=
 if
> CONFIG_IP_VS_IPV6 is not enabled:
>
> ../net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=E2=
=80=99:
> ../net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variable =
=E2=80=98net=E2=80=99 [-Wunused-variable]
>
> After the net refactoring there is only 1 user; push the reference to=
 the
> 1 user. While the line length slightly exceeds 80 it seems to be the
> best change.
>
> Fixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")

    Minor nit: missing space before (. Could be probbably fixed while a=
pplying...

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> Acked-by: Julian Anastasov <ja@ssi.bg>
> [horms: updated subject]
> Signed-off-by: Simon Horman <horms@verge.net.au>

[...]

MBR, Sergei
