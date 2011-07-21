From: Simon Horman <horms@verge.net.au>
Subject: Re: ipvs oops in 3.0-rc7
Date: Thu, 21 Jul 2011 14:40:33 +0900
Message-ID: <20110721054033.GA8299@verge.net.au>
References: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Jul 20, 2011 at 08:50:19PM -0700, Randy Dunlap wrote:
> I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading and unloading
> modules.  Any chance this is already fixed?  I can test current git, but I
> wanted to ask first.
> 
> Looks like it is on the second module load of ip_vs (i.e.,
> modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).

Hi Randy,

I don't believe that this problem has been resolved (or observed before).
