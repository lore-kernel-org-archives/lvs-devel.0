From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 1116/1285] Replace numeric parameter like 0444 with
 macro
Date: Tue, 2 Aug 2016 20:07:11 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1608022006070.25634@nerf40.vanv.qr>
References: <20160802121754.24527-1-baolex.ni@intel.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160802121754.24527-1-baolex.ni@intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baole Ni <baolex.ni@intel.com>
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, chuansheng.liu@intel.com


On Tuesday 2016-08-02 14:17, Baole Ni wrote:

>I find that the developers often just specified the numeric value
>when calling a macro which is defined with a parameter for access permission.
>As we know, these numeric value for access permission have had the corresponding macro,
>and that using macro can improve the robustness and readability of the code,
>thus, I suggest replacing the numeric parameter with the macro.
>
> static int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
>-module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
>+module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, S_IRUSR | S_IRGRP | S_IROTH);

We have S_IRUGO for this.
