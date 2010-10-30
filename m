From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH] IPVS: Backup, Adding IPv6 address packing
Date: Sat, 30 Oct 2010 15:53:03 +0900
Message-ID: <20101030065303.GL26727@verge.net.au>
References: <1288354920-10994-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288354920-10994-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Fri, Oct 29, 2010 at 02:22:00PM +0200, Hans Schillstrom wrote:
> Add pack/unpack of IPv6 address in sync message
> in binary form similar to the ASCII ::
> 
> A packed IPv6 address constists of -
> first byte
>   high nibble first segment leng in bytes
>   low nibble  possition of last segment.
> then
>   First segemnt i.e. left side of ::
>   Last segment right side of ::
> 
> Examle  FC00::2
> unpacked FC00 0000 0000 0000 0000 0000 0000 0002
> packed   1F FC02
> Example 2 2003::2:100
> unpacked 2003 0000 0000 0000 0000 0000 0002 0100
> packed   2D 20 03 02 01 00

Hi Hans,

are you sure the space saved is worth the additional complexity
that this patch introduces?
