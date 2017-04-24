From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PROBLEM: IPVS incorrectly reverse-NATs traffic to LVS host
Date: Mon, 24 Apr 2017 21:42:52 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1704242140290.2690@ja.home.ssi.bg>
References: <CAEo=OUnG+Bn04XaEkwHpL2bt6bEZXP_F6RSa9HDN=VjXdOxpoQ@mail.gmail.com> <alpine.LFD.2.20.1704221417080.1974@ja.home.ssi.bg> <CAEo=OUmQb0FGQ2Lm+H4RNKTZD7hVKBJ+LTe2Sjy+BgW84yJ_ug@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAEo=OUmQb0FGQ2Lm+H4RNKTZD7hVKBJ+LTe2Sjy+BgW84yJ_ug@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Moriarty <nick.moriarty@york.ac.uk>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Mon, 24 Apr 2017, Nick Moriarty wrote:

> Many thanks for your prompt fix!  I've now tested this patch against
> the 4.11.0-rc8 kernel on Ubuntu, and I can confirm that my check
> script is no longer seeing incorrect addresses in its responses.
> 
> Could you please keep me posted as this is merged?

	Sure. Thanks for the confirmation! I'll do some
tests and will post official patch in few days.

Regards

--
Julian Anastasov <ja@ssi.bg>
