From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] one-packet scheduling
Date: Fri, 25 Jun 2010 09:40:32 +0900
Message-ID: <20100625004031.GH2687@verge.net.au>
References: <20100624122919.GB26308@bombadil.infradead.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100624122919.GB26308@bombadil.infradead.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Graf <tgraf@infradead.org>
Cc: lvs-devel@vger.kernel.org

On Thu, Jun 24, 2010 at 08:29:19AM -0400, Thomas Graf wrote:
> Hi,
> 
> This is an updated version of Julian's One Packet Scheduler patch. It is
> based on http://marc.info/?l=linux-virtual-server&m=112800257026121&w=2
> with all issues raised in previous discussions addressed.

Hi Thomas,

a very similar change was recently added to nf-next-2.6,
though it hasn't shown up in net-next-2.6 yet.

The main difference is that your version has ip_vs_onepacket_enabled(),
where as the merged version is open-coded. Do you have any interest in
sending that change by itself?  If not, I'm happy to do the minor legwork.
