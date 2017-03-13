From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 net-next 0/4] update ipvs sysctl document
Date: Mon, 13 Mar 2017 10:14:30 +0100
Message-ID: <20170313091430.GA17847@verge.net.au>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
 <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
 <alpine.LFD.2.11.1702212154590.1840@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1489396474; bh=97rMA8JmQ7Fiq89mNcUCXKTqXEXofGvQGTag0gEc7FA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=IvuwHNijxmeiYuO8unRoWIJhcJEKJG7GuxpzFeAl8Y1hBhF/nH2KbgsTwxK7RV4ip
         U20KFsjIj/vVEn1vxieVIP+QUOEVYfGyphcn2oaNrJb3FEf9RVQr5CETL9ByQQudby
         eZuGQTFgBWLBUX94svGxlGF5pkZGZWDFLFWgMDss=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1702212154590.1840@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hangbin Liu <liuhangbin@gmail.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

On Tue, Feb 21, 2017 at 10:01:44PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 20 Feb 2017, Hangbin Liu wrote:
> 
> > Fix and add some new ipvs sysctl options. Also use tab instead of
> > whitespaces to indent the descriptions.
> > 
> > V2: Fix some descriptions based on Julian's advice.
> > 
> > Hangbin Liu (4):
> >   ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
> >   ipvs: Document sysctl sync_qlen_max and sync_sock_size
> >   ipvs: Document sysctl sync_ports
> >   ipvs: Document sysctl pmtu_disc
> 
> 	All patches look ok to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, can we keep this patchset while in merge window?

Hi,

I apologise for the extended delay in dealing with this - I have been ill.

I have queued these up for v4.12 in ipvs-next as that seems to be the most
appropriate course of action at this time. Please let me know if you'd like
to explore a different approach.
