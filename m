From: Daniel Drown <dan-lvs@drown.org>
Subject: Re: multiple local nodes (patch)
Date: Wed, 24 Dec 2008 22:11:51 +0000
Message-ID: <20081224221151.GH14163@vps.drown.org>
References: <20081208214012.GP30076@vps.drown.org> <20081224035118.GC28817@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224035118.GC28817@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

On Wed, 24 Dec 2008, Simon Horman wrote:
> sorry to take so long to respond, I have been meaning to do so.
> 
> Your patch seems good to me (though I am somewhat biases as I wrote
> the patch you based your patch on). Would it be possible for you to
> 
> a) update the code to either DaveM's net-next-2.6 tree on git.kernel.org,
>    or at the very least one of the 2.6.29-rc releases? In particular
>    please note that the lvs code has moved from net/ipv4/ipvs/ to
>    net/netfilter/ipvs/ . Also, I think that you will need to rework
>    your checksum code changes a little to accomodate IPv6, which
>    has been merged into IPVS recently.
> 
> b) Provide a Signed-off-by line, an explanation of which can be found at
>    http://linux.yyz.us/patch-format.html

Certainly.  I'll have some time for this after the holidays.
