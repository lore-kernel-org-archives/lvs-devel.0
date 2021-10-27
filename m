From: yangxingwu <xingwu.yang@gmail.com>
Subject: Re: [PATCH] ipvs: Fix reuse connection if RS weight is 0
Date: Wed, 27 Oct 2021 09:43:31 +0800
Message-ID: <CA+7U5Jta_g2vCXiwScVVwLZppWp51TDOB7LxUxeundkPxNZYnA@mail.gmail.com>
References: <20211025115910.2595-1-xingwu.yang@gmail.com> <707b5fb3-6b61-c53-e983-bc1373aa2bf@ssi.bg>
 <CA+7U5JsSuwqP7eHj1tMHfsb+EemwrhZEJ2b944LFWTroxAnQRQ@mail.gmail.com>
 <1190ef60-3ad9-119e-5336-1c62522aec81@ssi.bg> <CA+7U5JvvsNejgOifAwDdjddkLHUL30JPXSaDBTwysSL7dhphuA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-doc-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8LJqS8zky7pcMbUa92VXQE1e4F/KCHrhH+dmA5eIbDw=;
        b=Spt2jzK0txE6TKglycyhopMhk7/Qs8AejfSjBab5DxG7mnLhZ31UyxEXNvk1wFHraj
         kYzExGTJtV/vgKU1aNpPxrUHN8OGuFQ3rWPFz5lElDm8k3b0hd2m8/gN2hbyJfIdg9X1
         zP+DzjQyWYq8UMzx3cUMSvZKRH1Z/9M1nnlexaqWV2dXbzVAle53OvqskgnsF/cWsXJ0
         6+7SjorfK+9+u/0AJS/7op54mV0GVycWs8Iw3hkPDhjmpaqNA3EEblpIztvAQPOz58gZ
         r/EykbTqZqpq8cMY/JjsOPJpU6R8ywr/CaF8viTwjNdZ4JCeSwDqwcCoZZewmNjskGnf
         LaBg==
In-Reply-To: <CA+7U5JvvsNejgOifAwDdjddkLHUL30JPXSaDBTwysSL7dhphuA@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, kadlec@netfilter.org, fw@strlen.de, "David S. Miller" <davem@davemloft.net>, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, corbet@lwn.net

Julian

what we want is if RS weight is 0, then no new connections should be
served even if conn_reuse_mode is 0, just as commit dc7b3eb900aa
("ipvs: Fix reuse connection if real server is
dead") trying to do

Pls let me know if there are any other issues of concern

On Tue, Oct 26, 2021 at 2:13 PM yangxingwu <xingwu.yang@gmail.com> wrote:
>
> thanks Julian
>
> yes, I know that the one-second delay issue has been fixed by commit
> f0a5e4d7a594e0fe237d3dfafb069bb82f80f42f if we set conn_reuse_mode to
> 1
>
> BUT  it's still NOT what we expected with sysctl settings
> (conn_reuse_mode == 0 && expire_nodest_conn == 1).
>
> We run kubernetes in extremely diverse environments and this issue
> happens a lot.
>
> On Tue, Oct 26, 2021 at 1:44 PM Julian Anastasov <ja@ssi.bg> wrote:
> >
> >
> >         Hello,
> >
> > On Tue, 26 Oct 2021, yangxingwu wrote:
> >
> > > thanks julian
> > >
> > > What happens in this situation is that if we set the wait of the
> > > realserver to 0 and do NOT remove the weight zero realserver with
> > > sysctl settings (conn_reuse_mode == 0 && expire_nodest_conn == 1), and
> > > the client reuses its source ports, the kernel will constantly
> > > reuse connections and send the traffic to the weight 0 realserver.
> >
> >         Yes, this is expected when conn_reuse_mode=0.
> >
> > > you may check the details from
> > > https://github.com/kubernetes/kubernetes/issues/81775
> >
> >         What happens if you try conn_reuse_mode=1? The
> > one-second delay in previous kernels should be corrected with
> >
> > commit f0a5e4d7a594e0fe237d3dfafb069bb82f80f42f
> > Date:   Wed Jul 1 18:17:19 2020 +0300
> >
> >     ipvs: allow connection reuse for unconfirmed conntrack
> >
> > > On Tue, Oct 26, 2021 at 2:12 AM Julian Anastasov <ja@ssi.bg> wrote:
> > > >
> > > > On Mon, 25 Oct 2021, yangxingwu wrote:
> > > >
> > > > > Since commit dc7b3eb900aa ("ipvs: Fix reuse connection if real server is
> > > > > dead"), new connections to dead servers are redistributed immediately to
> > > > > new servers.
> > > > >
> > > > > Then commit d752c3645717 ("ipvs: allow rescheduling of new connections when
> > > > > port reuse is detected") disable expire_nodest_conn if conn_reuse_mode is
> > > > > 0. And new connection may be distributed to a real server with weight 0.
> > > >
> > > >         Your change does not look correct to me. At the time
> > > > expire_nodest_conn was created, it was not checked when
> > > > weight is 0. At different places different terms are used
> > > > but in short, we have two independent states for real server:
> > > >
> > > > - inhibited: weight=0 and no new connections should be served,
> > > >         packets for existing connections can be routed to server
> > > >         if it is still available and packets are not dropped
> > > >         by expire_nodest_conn.
> > > >         The new feature is that port reuse detection can
> > > >         redirect the new TCP connection into a new IPVS conn and
> > > >         to expire the existing cp/ct.
> > > >
> > > > - unavailable (!IP_VS_DEST_F_AVAILABLE): server is removed,
> > > >         can be temporary, drop traffic for existing connections
> > > >         but on expire_nodest_conn we can select different server
> > > >
> > > >         The new conn_reuse_mode flag allows port reuse to
> > > > be detected. Only then expire_nodest_conn has the
> > > > opportunity with commit dc7b3eb900aa to check weight=0
> > > > and to consider the old traffic as finished. If a new
> > > > server is selected, any retrans from previous connection
> > > > would be considered as part from the new connection. It
> > > > is a rapid way to switch server without checking with
> > > > is_new_conn_expected() because we can not have many
> > > > conns/conntracks to different servers.
> >
> > Regards
> >
> > --
> > Julian Anastasov <ja@ssi.bg>
