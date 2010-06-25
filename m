From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] one-packet scheduling
Date: Fri, 25 Jun 2010 03:40:20 -0400
Message-ID: <20100625074020.GA29930@bombadil.infradead.org>
References: <20100624122919.GB26308@bombadil.infradead.org>
 <20100625004031.GH2687@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100625004031.GH2687@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

On Fri, Jun 25, 2010 at 09:40:32AM +0900, Simon Horman wrote:
> a very similar change was recently added to nf-next-2.6,
> though it hasn't shown up in net-next-2.6 yet.
> 
> The main difference is that your version has ip_vs_onepacket_enabled(),
> where as the merged version is open-coded. Do you have any interest in
> sending that change by itself?  If not, I'm happy to do the minor legwork.

Ah, I missed that. I'll send that cleanup work as follow-up.

Thanks!
