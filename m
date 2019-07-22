From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/4] ipvs: reduce kernel stack usage
Date: Mon, 22 Jul 2019 12:16:51 +0200
Message-ID: <CAK8P3a03wShPgL85K-0W3UUc3QJWLbbs+ZVAnkKLkqg00vVehw@mail.gmail.com>
References: <20190628123819.2785504-1-arnd@arndb.de> <20190628123819.2785504-4-arnd@arndb.de>
 <alpine.LFD.2.21.1906302308280.3788@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.21.1906302308280.3788@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Kees Cook <keescook@chromium.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, James Smart <james.smart@broadcom.com>, Dick Kennedy <dick.kennedy@broadcom.com>, "James E . J . Bottomley" <jejb@linux.ibm.com>, "Martin K . Petersen" <martin.petersen@oracle.com>, Larry Finger <Larry.Finger@lwfinger.net>, Florian Schilhabel <florian.c.schilhabel@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Morris <jmorris@namei.org>, linux-scsi <linux-scsi@vger.kernel.org>

On Sun, Jun 30, 2019 at 10:37 PM Julian Anastasov <ja@ssi.bg> wrote:
> On Fri, 28 Jun 2019, Arnd Bergmann wrote:

> >       struct ip_vs_conn *ctl_cp = cp->control;
> >       if (!ctl_cp) {
> > -             IP_VS_ERR_BUF("request control DEL for uncontrolled: "
> > -                           "%s:%d to %s:%d\n",
> > -                           IP_VS_DBG_ADDR(cp->af, &cp->caddr),
> > -                           ntohs(cp->cport),
> > -                           IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
> > -                           ntohs(cp->vport));
> > +             pr_err("request control DEL for uncontrolled: "
> > +                    "%pISp to %pISp\n",

(replying a bit late)

>         ip_vs_dbg_addr() used compact form (%pI6c), so it would be
> better to use %pISc and %pISpc everywhere in IPVS...

done

>         Also, note that before now port was printed with %d and
> ntohs() was used, now port should be in network order, so:
>
> - ntohs() should be removed

done

> - htons() should be added, if missing. At first look, this case
> is not present in IPVS, we have only ntohs() usage

I found one case in ip_vs_ftp_in() that needs it in order to subtract one:

                IP_VS_DBG(7, "protocol %s %pISpc %pISpc\n",
                          ip_vs_proto_name(ipvsh->protocol),
-                         IP_VS_DBG_SOCKADDR(cp->af, &to, ntohs(port)),
+                         IP_VS_DBG_SOCKADDR(cp->af, &to, port),
                          IP_VS_DBG_SOCKADDR(cp->af, &cp->vaddr,
-                                             ntohs(cp->vport)-1));
+                                            htons(ntohs(cp->vport)-1)));

Thanks for the review, I'll send a new patch after some more
build testing on the new version.

       Arnd
