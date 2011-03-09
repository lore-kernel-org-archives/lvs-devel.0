From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Fix variable assignment in ip_vs_notrack
Date: Thu, 10 Mar 2011 07:05:35 +0900
Message-ID: <20110309220535.GB23960@verge.net.au>
References: <alpine.LNX.2.00.1103092250510.4471@swampdragon.chaosbits.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1103092250510.4471@swampdragon.chaosbits.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, trivial@kernel.org

On Wed, Mar 09, 2011 at 10:55:05PM +0100, Jesper Juhl wrote:
> There's no sense to 'ct = ct = ' in ip_vs_notrack(). Just assign 
> nf_ct_get()'s return value directly to the pointer variable 'ct' once.

Thanks Jesper, applied to lvs-test-2.6.
