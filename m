From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: increase ip_vs_conn_tab_bits range for 64BIT
Date: Tue, 16 May 2023 08:35:01 +0300 (EEST)
Message-ID: <02f51077-3cda-b4aa-a060-3c420cc72942@ssi.bg>
References: <20230412-increase_ipvs_conn_tab_bits-v2-1-994c0df018e6@gmail.com> <56b88a99-db88-36e4-9ff1-a5d940578108@ssi.bg> <CACXxYfy+yoLLFr0W9HYuM78GjzJsQvbHnm43uRQbor_ncQdMgw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CACXxYfy+yoLLFr0W9HYuM78GjzJsQvbHnm43uRQbor_ncQdMgw@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>


	Hello,

On Mon, 15 May 2023, Abhijeet Rastogi wrote:

> Hi Julian Anastasov,
> 
> >Can you keep the previous line width of the above help
> because on standard 80-width window the help now gets truncated in
> make menuconfig.
> 
> Refer this screenshot: https://i.imgur.com/9LgttpC.png
> 
> Sorry for the confusion, I was already expecting this comment. The
> patch had a few words added, hence it feels like many lines have
> changed. However, no line actually exceeds 80 width.
> 
> Longest line is still 80-width max. Do you prefer I reduce it to a
> lower number like 70?

	I'm checking in menuconfig where the help text is displayed.
The word "lasting" is visible up to "last". So, 3 columns are not
visible. In editor, this line is 84, may be up to 80 should be good.
You are using editor that represents Tabs as 4 spaces, that is why
it looks like it fits in 80. Open Kconfig in less. But in editor/less
does not matter because menuconfig simply ignores the leading spaces
in Kconfig and considers the text length which should be no more
than 70.

Regards

--
Julian Anastasov <ja@ssi.bg>

