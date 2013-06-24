From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: add sync_persist_mode flag
Date: Mon, 24 Jun 2013 22:57:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306242246140.1593@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com>
 <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <51C5887A.1070301@gmail.com> <alpine.LFD.2.00.1306221510100.1577@ja.ssi.bg> <51C612F2.6080500@gmail.com> <alpine.LFD.2.00.1306231108450.1584@ja.ssi.bg> <51C85995.1060500@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51C85995.1060500@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 24 Jun 2013, Aleksey Chudov wrote:

> Hello,
> 
> Pair of LVS servers with a modified kernel worked under load for several days
> without any problems.
> 
> I completed several additional tests. I analyzed the traffic to the LVS
> servers using tcpdump. There is not SYN or RST packets spike at the time of
> migration of IP address. Thus, most of the connections have continued to
> operate normally. I also once again made sure that most of clients remain on
> the same real servers.
> 
> Seems like sync_persist_mode combined with sloppy_tcp works fine.

	Thanks! I just posted the patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
