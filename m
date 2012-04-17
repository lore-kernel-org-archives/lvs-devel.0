From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Tue, 17 Apr 2012 23:57:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204172242430.1984@ja.ssi.bg>
References: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com> <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg> <201204171315.12686.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201204171315.12686.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>


	Hello,

On Tue, 17 Apr 2012, Hans Schillstrom wrote:

> I wonder if we are chasing ghosts...
> 
> With proper fault handling I can't even see a case when it (net->ipvs) can be used.
> Can you see a case when it could happen?
> Still we can set it to NULL on error exit and cleanup as you suggested, that doesn't harm I think.
> 
> A. If you add a netns and it fails the entire ns will be rolled back, 
>    and no access to that ns can occur.
>    That ns does not exist

	Agreed

> B. If you insert ip_vs.ko when having one or more name spaces and 
>    __ip_vs_init() returns an error the module will be unloaded.
>    All ready loaded ns will not be affected.

	Yes, ip_vs_init fails.

> C. insmod of ex. ip_vs_ftp only affects loaded name spaces
>    and if the load of ip_vs_ftp fails it will be unloaded without affecting ip_vs(.ko)
>    (If ip_vs.ko is not loaded then it has to be loaded first case B...)
> 
> With a "compiled in" ip_vs case B doesn't exist.

	It is this case that can happen, we can only guess how
difficult is to get ENOMEM here. IIRC, we can generate only
ENOMEM error on IPVS core load.

	I assume Simon has such setup and changes code to
trigger load error. When I generate ENOMEM on IPVS core init
for such case I get ENOENT from register_ip_vs_app when
patch 1 and 2 for apps are applied, i.e. net->ipvs is NULL.
You can check it with NF_CONNTRACK=y, IP_VS=y and
IP_VS_FTP=m. You only need to trigger ENOMEM in __ip_vs_init.

> With proper fault handling i.e. all ways returning fault codes to the netns init,
> there is no need for checking for  "if (!net->ipvs)" or any other action.

	Probably but one check on load does not hurt much.

Regards

--
Julian Anastasov <ja@ssi.bg>
