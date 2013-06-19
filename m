From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Wed, 19 Jun 2013 22:25:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306192221400.1823@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com>
 <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Wed, 19 Jun 2013, Julian Anastasov wrote:

> +static inline bool in_peristence(struct ip_vs_conn *cp)

	Ops :)

s/in_peristence/in_persistence/

Regards

--
Julian Anastasov <ja@ssi.bg>
