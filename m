From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ip_vs_sh: fix build
Date: Thu, 30 May 2013 09:42:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305300939560.1671@ja.ssi.bg>
References: <51A611CF02000078000D99A6@nat28.tlf.novell.com> <alpine.LFD.2.00.1305292219170.1951@ja.ssi.bg> <51A6F642020000780009B66A@nat28.tlf.novell.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51A6F642020000780009B66A@nat28.tlf.novell.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <jbeulich@suse.com>
Cc: wensong@linux-vs.org, pablo@netfilter.org, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Thu, 30 May 2013, Jan Beulich wrote:

> CONFIG_IP_VS_DH_TAB_BITS is always 8 (due to not coming from any
> Kconfig setting), and hence not a problem at this point. If it is being planned
> to make configurable, then that change should at once flip the structure
> members.

	Aha, OK.

Regards

--
Julian Anastasov <ja@ssi.bg>
