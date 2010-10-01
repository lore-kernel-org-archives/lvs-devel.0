From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v2 08/12] [PATCH 08/12] IPVS: Add persistence engine data
 to /proc/net/ip_vs_conn
Date: Sat, 2 Oct 2010 00:50:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010020048030.2462@ja.ssi.bg>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net> <20101001143942.382352880@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20101001143942.382352880@akiko.akashicho.tokyo.vergenet.net>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>


 	Hello,

On Fri, 1 Oct 2010, Simon Horman wrote:

> Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-10-01 22:27:17.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-10-01 22:27:32.000000000 +0900
> @@ -938,30 +938,44 @@ static int ip_vs_conn_seq_show(struct se
>
> 	if (v == SEQ_START_TOKEN)
> 		seq_puts(seq,
> -   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires\n");
> +   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires PEName PEData\n");
> 	else {
> 		const struct ip_vs_conn *cp = v;
> +		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
> +		size_t len = 0;
> +

 	Add check for cp->dest, it is optional:

> +		if (cp->dest->svc->pe && cp->dest->svc->pe->show_pe_data) {
> +			pe_data[0] = ' ';
> +			len = strlen(cp->dest->svc->pe->name);
> +			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
> +			pe_data[len + 1] = ' ';
> +			len += 2;
> +			len += cp->dest->svc->pe->show_pe_data(cp,
> +							       pe_data + len);
> +		}
> +		pe_data[len] = '\0';

Regards

--
Julian Anastasov <ja@ssi.bg>
