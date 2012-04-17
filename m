From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Tue, 17 Apr 2012 13:15:10 +0200
Message-ID: <201204171315.12686.hans.schillstrom@ericsson.com>
References: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com> <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

Hello Julian
On Monday 16 April 2012 16:25:23 Julian Anastasov wrote:
> 
> 	Hello,
[snip]
> 
> 	Note that net_generic() and net->ipvs can not be
> used after ops_exit/ops_free and failed ops_init.
> 

I wonder if we are chasing ghosts...

With proper fault handling I can't even see a case when it (net->ipvs) can be used.
Can you see a case when it could happen?
Still we can set it to NULL on error exit and cleanup as you suggested, that doesn't harm I think.

A. If you add a netns and it fails the entire ns will be rolled back, 
   and no access to that ns can occur.
   That ns does not exist

B. If you insert ip_vs.ko when having one or more name spaces and 
   __ip_vs_init() returns an error the module will be unloaded.
   All ready loaded ns will not be affected.

C. insmod of ex. ip_vs_ftp only affects loaded name spaces
   and if the load of ip_vs_ftp fails it will be unloaded without affecting ip_vs(.ko)
   (If ip_vs.ko is not loaded then it has to be loaded first case B...)

With a "compiled in" ip_vs case B doesn't exist.

With proper fault handling i.e. all ways returning fault codes to the netns init,
there is no need for checking for  "if (!net->ipvs)" or any other action.

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
