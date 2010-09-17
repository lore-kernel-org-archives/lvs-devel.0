From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] ipvs: Netfilter connection tracking changes
Date: Fri, 17 Sep 2010 22:38:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009172232520.2923@u.domain.uli>
References: <Pine.LNX.4.58.1009162342590.6976@u.domain.uli> <4C935EE3.5070207@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4C935EE3.5070207@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Fri, 17 Sep 2010, Patrick McHardy wrote:

> This one doesn't compile cleanly with CONFIG_IP_VS_NFCT=n:
> 
>   CC [M]  net/netfilter/ipvs/ip_vs_ftp.o
> net/netfilter/ipvs/ip_vs_ftp.c: In function 'ip_vs_ftp_out':
> net/netfilter/ipvs/ip_vs_ftp.c:242: error: implicit declaration of
> function 'ip_vs_nfct_expect_related'

	I'm able to reproduce it only by commenting
CONFIG_IP_VS_FTP and CONFIG_IP_VS_NFCT and then this command fails:

make net/netfilter/ipvs/ip_vs_ftp.o

	In all other cases if CONFIG_IP_VS_FTP is enabled
the 'select IP_VS_NFCT' does its job and enables
CONFIG_IP_VS_NFCT. Am I missing something?

> Please fix this and resend.

Regards

--
Julian Anastasov <ja@ssi.bg>
