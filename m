From: Chris Maness <christopher.maness@gmail.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to
 register functions in sysctl
Date: Mon, 7 Aug 2023 16:00:49 -0700
Message-ID: <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org>
 <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="00000000000061316406025d38ac"
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 29BD661224
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 058B160D73
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 93001410DE
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 8C09E410C5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20221208; t=1691449261; x=1692054061;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=Mv53An7DfRcY3zqjcaunX8XH6mWtZiqor85B2Nma1PU=;
 b=jJnuIodvIO/bHZXVit3eNtPLAjNiC7mOQqw2UmJ9nkW5tMvb+x5z3uL2a5+o3ZM+Qg
 2q/ku8BATAd2TaNHIpTWPXd9dxGpLCtRqSdU9oCOZ66kXMP47PkiUoZYduRn138beNxW
 vFBxyTlxgWlqMDqAWRlCTnO5ZZANqMr2sjiakot7tjyZUcoZ2t/uoKzziz3jBCnFVvmK
 KqngywwhgtrhdVEFiliQbnUFDqP5cExs+9oQRcD2DkylXi/C8/dg42OWmEGlIfmGUW4n
 eZnL9VI4dVY28fI4KEWTlA5f2i6lvXqEtuHevuN2iMkxE4HPIkzsOD3+gRwdC4+fM6pF
 Cakg==
In-Reply-To: <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Joel Granados <j.granados@samsung.com>, Alexander Aring <alex.aring@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, netfilter-devel@vger.kernel.org, Eric Dumazet <edumazet@google.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Paolo Abeni <pabeni@redhat.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Tony Lu <tonylu@linux.alibaba.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Will Deacon <will@kernel.org>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netf>

--00000000000061316406025d38ac
Content-Type: text/plain; charset="UTF-8"

When are these likely to hit the mainline release code?

On Mon, Aug 7, 2023 at 2:59 PM Luis Chamberlain <mcgrof@kernel.org> wrote:

> On Mon, Jul 31, 2023 at 02:36:50PM -0700, Luis Chamberlain wrote:
> > > Joel Granados (14):
> > >   sysctl: Prefer ctl_table_header in proc_sysctl
> > >   sysctl: Use ctl_table_header in list_for_each_table_entry
> > >   sysctl: Add ctl_table_size to ctl_table_header
> > >   sysctl: Add size argument to init_header
> > >   sysctl: Add a size arg to __register_sysctl_table
> > >   sysctl: Add size to register_sysctl
> > >   sysctl: Add size arg to __register_sysctl_init
> >
> > This is looking great thanks, I've taken the first 7 patches above
> > to sysctl-next to get more exposure / testing and since we're already
> > on rc4.
>
> Ok I havent't heard much more feedback from networking folks, and
> since this is mostly sysctl love I've taken in the rest of these
> patches. Thanks to Jani Nikula for the reviews and to Greg KH for
> the suggestion on simplifying things.
>
> Let's see what busts in linux-next, and if anything does I can reset
> my tree back to only the first 7 patches.
>
>   Luis
>
-- 
Thanks,
Chris Maness
-Sent from my iPhone

--00000000000061316406025d38ac
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">When are these likely to hit the mainline release code?</=
div><div><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_att=
r">On Mon, Aug 7, 2023 at 2:59 PM Luis Chamberlain &lt;<a href=3D"mailto:mc=
grof@kernel.org">mcgrof@kernel.org</a>&gt; wrote:<br></div><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">On Mon, Jul 31, 2023 at 02:36:50PM -0700, Luis Chamberlain w=
rote:<br>
&gt; &gt; Joel Granados (14):<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Prefer ctl_table_header in proc_sysctl<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Use ctl_table_header in list_for_each_table_e=
ntry<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Add ctl_table_size to ctl_table_header<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Add size argument to init_header<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Add a size arg to __register_sysctl_table<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Add size to register_sysctl<br>
&gt; &gt;=C2=A0 =C2=A0sysctl: Add size arg to __register_sysctl_init<br>
&gt; <br>
&gt; This is looking great thanks, I&#39;ve taken the first 7 patches above=
<br>
&gt; to sysctl-next to get more exposure / testing and since we&#39;re alre=
ady<br>
&gt; on rc4.<br>
<br>
Ok I havent&#39;t heard much more feedback from networking folks, and<br>
since this is mostly sysctl love I&#39;ve taken in the rest of these<br>
patches. Thanks to Jani Nikula for the reviews and to Greg KH for<br>
the suggestion on simplifying things.<br>
<br>
Let&#39;s see what busts in linux-next, and if anything does I can reset<br=
>
my tree back to only the first 7 patches.<br>
<br>
=C2=A0 Luis<br>
</blockquote></div></div><span class=3D"gmail_signature_prefix">-- </span><=
br><div dir=3D"ltr" class=3D"gmail_signature" data-smartmail=3D"gmail_signa=
ture">Thanks,<br>Chris Maness<br>-Sent from my iPhone</div>

--00000000000061316406025d38ac--
