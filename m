From: Hannes Eder <heder@google.com>
Subject: Re: [RFC][PATCH 2/5] netfilter: xt_ipvs (netfilter matcher for ipvs)
Date: Tue, 28 Jul 2009 16:55:01 +0200
Message-ID: <b5ddba180907280755k725440fag79d39f18ebc7d28d@mail.gmail.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
	 <20090727134621.12897.75558.stgit@jazzy.zrh.corp.google.com>
	 <alpine.LSU.2.00.0907272017280.20984@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248792907; bh=9qBTFdShFzAZKwTr166KyYQ/xGI=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=ZWm4nzzjBj0xYR++7v
	eyHYN5E+qdGtyr+VtY+W57TrrMNKzdR265unhj8ZXdURLSN0Q1Sg6wAxKCN3ozaDtmr
	g==
In-Reply-To: <alpine.LSU.2.00.0907272017280.20984@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 27, 2009 at 20:35, Jan Engelhardt<jengelh@medozas.de> wrote=
:
>
> On Monday 2009-07-27 15:46, Hannes Eder wrote:
>>--- /dev/null
>>+++ b/include/linux/netfilter/xt_ipvs.h
>>@@ -0,0 +1,32 @@
>>+#ifndef _XT_IPVS_H
>>+#define _XT_IPVS_H 1
>>+
>>+#ifndef _IP_VS_H
>
> Do the definitions (should probably be enums) exist in
> very old <linux/ip_vs.h>? Then maybe you can get rid of them
> from xt_ipvs.h.

Definitions removed from xt_ipvs.h.  For xt_ipvs.c I just included
linux/ip_vs.h.  For libxt_ipvs (user space library) I added the entire
linux/ip_vs.h.  Do you think this is better?

>>+#define IP_VS_CONN_F_FWD_MASK 0x0007 =A0 =A0 =A0 =A0 =A0/* mask for =
the fwd methods */
>>+#define IP_VS_CONN_F_MASQ =A0 =A0 0x0000 =A0 =A0 =A0 =A0 =A0/* masqu=
erading/NAT */
>>+#define IP_VS_CONN_F_LOCALNODE =A0 =A0 =A0 =A00x0001 =A0 =A0 =A0 =A0=
 =A0/* local node */
>>+#define IP_VS_CONN_F_TUNNEL =A0 0x0002 =A0 =A0 =A0 =A0 =A0/* tunneli=
ng */
>>+#define IP_VS_CONN_F_DROUTE =A0 0x0003 =A0 =A0 =A0 =A0 =A0/* direct =
routing */
>>+#define IP_VS_CONN_F_BYPASS =A0 0x0004 =A0 =A0 =A0 =A0 =A0/* cache b=
ypass */
>>+#endif
>>+
>>+#define XT_IPVS_IPVS =A0 =A0 =A0 =A0 =A00x01 /* this is implied by a=
ll other options */
>>+#define XT_IPVS_PROTO =A0 =A0 =A0 =A0 0x02
>>+#define XT_IPVS_VADDR =A0 =A0 =A0 =A0 0x04
>>+#define XT_IPVS_VPORT =A0 =A0 =A0 =A0 0x08
>>+#define XT_IPVS_DIR =A0 =A0 =A0 =A0 =A0 0x10
>>+#define XT_IPVS_METHOD =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x20
>>+#define XT_IPVS_MASK =A0 =A0 =A0 =A0 =A0(0x40 - 1)
>>+#define XT_IPVS_ONCE_MASK =A0 =A0 (XT_IPVS_MASK & ~XT_IPVS_IPVS)
>>+
>>+struct xt_ipvs {
>>+ =A0 =A0 =A0union nf_inet_addr =A0 =A0 =A0vaddr, vmask;
>>+ =A0 =A0 =A0__be16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vport;
>>+ =A0 =A0 =A0u_int16_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 l4proto;
>>+ =A0 =A0 =A0u_int16_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 fwd_method;
>>+
>>+ =A0 =A0 =A0u_int8_t invert;
>>+ =A0 =A0 =A0u_int8_t bitmask;
>>+};
>
> As per the "Writing Netfilter modules" e-book, __u16/__u8 is required=
=2E

Done.

>>+config NETFILTER_XT_MATCH_IPVS
>>+ =A0 =A0 =A0tristate '"ipvs" match support'
>>+ =A0 =A0 =A0depends on NETFILTER_ADVANCED
>>+ =A0 =A0 =A0help
>>+ =A0 =A0 =A0 =A0This option allows you to match against ipvs propert=
ies of a packet.
>>+
>>+ =A0 =A0 =A0 =A0 =A0To compile it as a module, choos M here. =A0If u=
nsure, say N.
>>+
>IMHO the "to compile it as a module, choos[e] M" is a relict from
> old times and should just be dropped. These days, I stupilate,
> everyone knows that M makes modules. And if it doesnot, then
> it's not allowed by Kconfig :>

Done.

>>+MODULE_AUTHOR("Hannes Eder <heder@google.com>");
>>+MODULE_DESCRIPTION("Xtables: match ipvs");
>
> "Match IPVS connection properties" is what you previously stated,
> and which I think is good. Use it here, too.

Done.

>>+bool ipvs_mt(const struct sk_buff *skb, const struct xt_match_param =
*par)
>>+{
>>+ =A0 =A0 =A0const struct xt_ipvs *data =3D par->matchinfo;
>>+ =A0 =A0 =A0const u_int8_t family =3D par->family;
>>+ =A0 =A0 =A0struct ip_vs_iphdr iph;
>>+ =A0 =A0 =A0struct ip_vs_protocol *pp;
>>+ =A0 =A0 =A0struct ip_vs_conn *cp;
>>+ =A0 =A0 =A0int af;
>>+ =A0 =A0 =A0bool match =3D true;
>>+
>>+ =A0 =A0 =A0if (data->bitmask =3D=3D XT_IPVS_IPVS) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D !!(skb->ipvs_property)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ !!(data->invert & XT_I=
PVS_IPVS);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>+ =A0 =A0 =A0}
>
> XT_IPVS_IPVS? What's that supposed to tell me...

Just matching aginst the skb->ipvs_property, I changed to name to
XT_IPVS_IPVS_PROPERTY.

> Anyway, this can be made much shorter, given that all following
> the "out" label is a return:

You are right.  For the moment, I'll keep it as is.  Having a single
entry/exit point makes it easier to instrument the function for
debugging.

>
> =A0 =A0 =A0 =A0if (data->bitmask =3D=3D XT_IPVS_IPVS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return skb->ipvs_property ^ !!(data->i=
nvert & XT_IPVS_IPVS);
>
>>+ =A0 =A0 =A0/* other flags than XT_IPVS_IPVS are set */
>>+ =A0 =A0 =A0if (!skb->ipvs_property) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>+ =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (!skb->ipvs_property)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
>>+ =A0 =A0 =A0ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
>>+
>>+ =A0 =A0 =A0if (data->bitmask & XT_IPVS_PROTO)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((iph.protocol =3D=3D data->l4proto)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ !(data->invert & XT_IPVS_PROTO=
)) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (iph.protocol =3D=3D data->l4proto =
^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!(data->invert & XT_IPVS_PROTO=
))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
>>+ =A0 =A0 =A0pp =3D ip_vs_proto_get(iph.protocol);
>>+ =A0 =A0 =A0if (unlikely(!pp)) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>+ =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (unlikely(pp =3D=3D NULL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> Only after here we really need goto (to put pp).
>
>>+ =A0 =A0 =A0/*
>>+ =A0 =A0 =A0 * Check if the packet belongs to an existing entry
>>+ =A0 =A0 =A0 */
>>+ =A0 =A0 =A0/* TODO: why does it only match in inverse? */
>
> FIXME: Figure it out :)

Still working on that ;)

>>+ =A0 =A0 =A0cp =3D pp->conn_out_get(af, skb, pp, &iph, iph.len, 1 /*=
 inverse */);
>>+ =A0 =A0 =A0if (unlikely(!cp)) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>+ =A0 =A0 =A0}
>>+
>>+ =A0 =A0 =A0/*
>>+ =A0 =A0 =A0 * We found a connection, i.e. ct !=3D 0, make sure to c=
all
>>+ =A0 =A0 =A0 * __ip_vs_conn_put before returning. =A0In our case jum=
p to out_put_con.
>>+ =A0 =A0 =A0 */
>>+
>>+ =A0 =A0 =A0if (data->bitmask & XT_IPVS_VPORT)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((cp->vport =3D=3D data->vport)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ !(data->invert & XT_IPVS_VPORT=
)) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_put_ct;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>+
>>+ =A0 =A0 =A0if (data->bitmask & XT_IPVS_DIR) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0/* TODO: implement */
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Yes please */

Here we go:

	if (data->bitmask & XT_IPVS_DIR) {
		enum ip_conntrack_info ctinfo;
		struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);

		if (ct =3D=3D NULL || ct =3D=3D &nf_conntrack_untracked) {
			match =3D false;
			goto out_put_cp;
		}

		if ((ctinfo >=3D IP_CT_IS_REPLY) ^
		    !!(data->invert & XT_IPVS_DIR)) {
			match =3D false;
			goto out_put_cp;
		}
	}

>>+ =A0 =A0 =A0}
>>+
>>+ =A0 =A0 =A0if (data->bitmask & XT_IPVS_METHOD)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (((cp->flags & IP_VS_CONN_F_FWD_MASK)=
 =3D=3D data->fwd_method)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ !(data->invert & XT_IPVS_METHO=
D)) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_put_ct;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>+
>>+ =A0 =A0 =A0if (data->bitmask & XT_IPVS_VADDR) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (af !=3D family) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_put_ct;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>+
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ipvs_mt_addrcmp(&cp->vaddr, &data->v=
addr, &data->vmask, af)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ !(data->invert & XT_IPVS_VADDR=
)) {
>
> I think the operator (^ in this case) always goes onto the same line =
as the ')'
> ((a) ^\n(b), not ((a)\n ^(b)), though some legacy code seems to do it
> random so-so.)

I changed it as suggested, though I could not find anything in
Documentation/CodingStyle about that.

>>+ =A0 =A0 =A0return match;
>>+}
>>+EXPORT_SYMBOL(ipvs_mt);
>
> What will be using ipvs_mt?

Nobody, EXPORT_SYMBOL removed.

>>+static struct xt_match xt_ipvs_mt_reg[] __read_mostly =3D {
>>+ =A0 =A0 =A0{
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =3D "ipvs",
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0.revision =A0 =3D 0,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0.family =A0 =A0 =3D NFPROTO_UNSPEC,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0.match =A0 =A0 =A0=3D ipvs_mt,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0.matchsize =A0=3D sizeof(struct xt_ipvs)=
,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0.me =A0 =A0 =A0 =A0 =3D THIS_MODULE,
>>+ =A0 =A0 =A0},
>>+};
>
> There is just one element, so no strict need for the [] array.

You are right.  Done.

Thanks for the review.

Cheers,
-Hannes
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
