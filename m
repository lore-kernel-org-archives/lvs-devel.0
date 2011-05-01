From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Mon, 2 May 2011 08:15:31 +0900
Message-ID: <20110501231530.GR10017@verge.net.au>
References: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
 <20110429064225.GA23958@verge.net.au>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC08232F0887@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC08232F0887@ESESSCMS0356.eemea.ericsson.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Hans =?utf-8?Q?Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, "ja@ssi.bg" <ja@ssi.bg>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

On Fri, Apr 29, 2011 at 11:48:39AM +0200, Hans Schillstr=C3=B6m wrote:
>=20
> >Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
> >
> >On Fri, Apr 29, 2011 at 08:25:28AM +0200, Hans Schillstrom wrote:
> > This patch series handles exit from a network name space.
> >
> >Hi Hans,
> >
> >thanks for your work on this.
> >I've looked over the patches and nothing catches my eye -
> >thanks for fixing up the things that I commented on previously.
> >
> >I think that patches 1 and 2 should be targeted at 2.6.39,
> >while the remainder look like 2.6.40 material. Does that
> >sound reasonable to you?
>=20
> I do prefer to keep them together,=20
> but if you want it in that way it's OK for me.

I understand that you'd like to keep things together,
but I think its too much change for .39 this late
in the rc series.

> We are doing a lot of tests right now with this patch set.
> If we found any issues I'll let you know.

Thanks
