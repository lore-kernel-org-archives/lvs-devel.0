From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 20 Jun 2013 23:09:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306202301310.1818@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com>
 <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <alpine.LFD.2.00.1306192221400.1823@ja.ssi.bg> <51C335B6.2000202@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51C335B6.2000202@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 20 Jun 2013, Aleksey Chudov wrote:

> Hi,
> 
> I'm trying to calculate how much memory will be needed to synchronize the
> persistent templates across the entire cluster. How much memory consumes one
> persistent template?

	Just like every connection, may be you can find
such message in dmesg/logs when IPVS starts:

	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
		sizeof(struct ip_vs_conn));

	You can also check 'slabtop' (cat /proc/slabinfo) on
load, look for ip_vs_conn. On my x86-32 platform it shows 240 bytes.
On x86-64 it should be more.

Regards

--
Julian Anastasov <ja@ssi.bg>
