From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 7/8] ipvs: add support for sync threads
Date: Mon, 23 Apr 2012 22:43:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204232241060.1890@ja.ssi.bg>
References: <1334872199-8826-1-git-send-email-ja@ssi.bg> <1334872199-8826-8-git-send-email-ja@ssi.bg> <20120423125412.GD20296@verge.net.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1249061230-1335210215=:1890"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120423125412.GD20296@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Aleksey Chudov <aleksey.chudov@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1249061230-1335210215=:1890
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Mon, 23 Apr 2012, Simon Horman wrote:

> > +	return ((int) cp >> (1 + ilog2(sizeof(*cp)))) & ipvs->threads_mask;
> >  }
> 
> Hi Julian,
> 
> My gcc running on x86_64 doesn't seem to like this cast.
> 
> # gcc --version
> gcc (Debian 4.6.3-1) 4.6.3
> # make
> ...
>   CC      net/netfilter/ipvs/ip_vs_est.o
> net/netfilter/ipvs/ip_vs_sync.c: In function ‘select_master_thread_id’:
> net/netfilter/ipvs/ip_vs_sync.c:398:10: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]

	Ops. I'll change this '(int)' with '(long)'. You
want new version for the whole patchset or just for this patch?

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1249061230-1335210215=:1890--
