From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH 1116/1285] Replace numeric parameter like 0444 with macro
Date: Tue, 2 Aug 2016 15:13:37 -0400
Message-ID: <20160802191337.GD36313@redhat.com>
References: <20160802121754.24527-1-baolex.ni@intel.com>
 <alpine.LSU.2.20.1608022006070.25634@nerf40.vanv.qr>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1608022006070.25634@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@inai.de>
Cc: Baole Ni <baolex.ni@intel.com>, Linux Networking Developer Mailing List <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, chuansheng.liu@intel.com

On Tue, Aug 02, 2016 at 08:07:11PM +0200, Jan Engelhardt wrote:
> 
> On Tuesday 2016-08-02 14:17, Baole Ni wrote:
> 
> >I find that the developers often just specified the numeric value
> >when calling a macro which is defined with a parameter for access permission.
> >As we know, these numeric value for access permission have had the corresponding macro,
> >and that using macro can improve the robustness and readability of the code,
> >thus, I suggest replacing the numeric parameter with the macro.
> >
> > static int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
> >-module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
> >+module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, S_IRUSR | S_IRGRP | S_IROTH);
> 
> We have S_IRUGO for this.

Aye, for further edification, Baole, please read include/linux/stat.h,
particularly this part:

#define S_IRWXUGO       (S_IRWXU|S_IRWXG|S_IRWXO)
#define S_IALLUGO       (S_ISUID|S_ISGID|S_ISVTX|S_IRWXUGO)
#define S_IRUGO         (S_IRUSR|S_IRGRP|S_IROTH)
#define S_IWUGO         (S_IWUSR|S_IWGRP|S_IWOTH)
#define S_IXUGO         (S_IXUSR|S_IXGRP|S_IXOTH)

I suspect many of the patches in this set should be using one of the above
defines instead, never mind the ridiculousness of firing off such a
massive set at once, with every patch having the same (often not correct)
title, and the highly questionable benefit of the set to begin with.

-- 
Jarod Wilson
jarod@redhat.com

