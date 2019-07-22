From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/4] ipvs: reduce kernel stack usage
Date: Mon, 22 Jul 2019 12:28:59 +0200
Message-ID: <CAK8P3a0xPDmNDbxRkN6ssobFLu1-JLvMG3MSai844hinj2Bs8A@mail.gmail.com>
References: <20190628123819.2785504-1-arnd@arndb.de>
 <20190628123819.2785504-4-arnd@arndb.de>
 <CA+FuTSexLuu8e1XHaY0ObGi46CgZnBpELecBr+kMgCU29Fa_gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CA+FuTSexLuu8e1XHaY0ObGi46CgZnBpELecBr+kMgCU29Fa_gw@mail.gmail.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>, 
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>, 
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Cc: James Morris <jmorris@namei.org>, driverdevel <devel@driverdev.osuosl.org>, linux-scsi <linux-scsi@vger.kernel.org>, James Smart <james.smart@broadcom.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, coreteam@netfilter.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Pablo Neira Ayuso <pablo@netfilter.org>, Wensong Zhang <wensong@linux-vs.org>, Dick Kennedy <dick.kennedy@broadcom.com>, Kees Cook <keescook@chromium.org>, "James E . J . Bottomley" <jejb@linux.ibm.com>, Simon Horman <horms@verge.net.au>, Florian Schilhabel <florian.c.schilhabel@googlemail.com>, "Martin K . Petersen" <martin.petersen@oracle.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Florian Westphal <fw@strlen.de>, linux-kernel <linux-kernel@vger.kernel.or>

On Fri, Jun 28, 2019 at 9:59 PM Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Fri, Jun 28, 2019 at 8:40 AM Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > With the new CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL option, the stack
> > usage in the ipvs debug output grows because each instance of
> > IP_VS_DBG_BUF() now has its own buffer of 160 bytes that add up
> > rather than reusing the stack slots:
> >
> > net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_sched_persist':
> > net/netfilter/ipvs/ip_vs_core.c:427:1: error: the frame size of 1052 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> > net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_new_conn_out':
> > net/netfilter/ipvs/ip_vs_core.c:1231:1: error: the frame size of 1048 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> > net/netfilter/ipvs/ip_vs_ftp.c: In function 'ip_vs_ftp_out':
> > net/netfilter/ipvs/ip_vs_ftp.c:397:1: error: the frame size of 1104 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> > net/netfilter/ipvs/ip_vs_ftp.c: In function 'ip_vs_ftp_in':
> > net/netfilter/ipvs/ip_vs_ftp.c:555:1: error: the frame size of 1200 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> >
> > Since printk() already has a way to print IPv4/IPv6 addresses using
> > the %pIS format string, use that instead,
>
> since these are sockaddr_in and sockaddr_in6, should that have the 'n'
> specifier to denote network byteorder?

I double-checked the implementation, and don't see that make any difference,
as 'n' is the default.

> >  include/net/ip_vs.h             | 71 +++++++++++++++++++--------------
> >  net/netfilter/ipvs/ip_vs_core.c | 44 ++++++++++----------
> >  net/netfilter/ipvs/ip_vs_ftp.c  | 20 +++++-----
> >  3 files changed, 72 insertions(+), 63 deletions(-)
> >
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index 3759167f91f5..3dfbeef67be6 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -227,6 +227,16 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
> >                        sizeof(ip_vs_dbg_buf), addr,                     \
> >                        &ip_vs_dbg_idx)
> >
> > +#define IP_VS_DBG_SOCKADDR4(fam, addr, port)                           \
> > +       (struct sockaddr*)&(struct sockaddr_in)                         \
> > +       { .sin_family = (fam), .sin_addr = (addr)->in, .sin_port = (port) }
>
> might as well set .sin_family = AF_INET here and AF_INET6 below?

That would work just same, but I don't see any advantage. As the family
and port members are the same between sockaddr_in and sockaddr_in6,
the compiler can decide to set these regardless to the argument values
regardless of the condition.

       Arnd
