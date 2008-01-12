From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
	realservers (WORKING)
Date: Sat, 12 Jan 2008 12:06:22 +0900
Message-ID: <20080112030620.GD7094@verge.net.au>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com> <Pine.LNX.4.64.0801100432180.28592@wm7d.net> <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com> <20080111041426.GF13135@verge.net.au> <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Sat, Jan 12, 2008 at 02:30:26AM +0100, Raphael Vallazza wrote:

[snip]

>> My other techincal question was do you think it would be
>> possible/desirable to make it a run-time option. I'm particularly
>> thinking of people with distro kernels and an adversion to  
>> recompiling,
>> as is the case for enterprise-types.
>
> Absolutely, what do you think about creating a proc file that allows to 
> switch at runtime? This way at compile time the user/distribution can 
> choose the default behaviour and the user could change it in /proc/ 
> sys/net/vs/input_method. If you all agree i'll try to find some to  
> implement it.

Yes, a proc file was what I had in mind. I think that the best thing to 
do would be to code it up as a separate (additional) patch and if it
flies you or I can send it on to netdev. Last time I asked about
adding proc entires no one complained. But thats not to say that
they won't think it should be handled a different way this time around.

But really the kernel/user-space interface isn't the meat of the
problem, and if it is then we are probably only talking about a small
patch anyway. Either way, refactoring shouldn't be too tedious.

I'll get to revieing your latest patches a little later, though
I don't forsee any significant problems.

[snip]

-- 
Horms

