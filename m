From: Graeme Fowler <graeme@graemef.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
	realservers (WORKING)
Date: Sat, 12 Jan 2008 10:07:12 +0000
Message-ID: <1200132432.14776.5.camel@ernie.internal.graemef.net>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
	 <Pine.LNX.4.64.0801100432180.28592@wm7d.net>
	 <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com>
	 <20080111041426.GF13135@verge.net.au>
	 <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: LVS Devel <lvs-devel@vger.kernel.org>

Hi all

On Sat, 2008-01-12 at 02:30 +0100, Raphael Vallazza wrote:
> I've attached patches for net-2.6 (works on 2.6.24-2.6.22) and  
> net-2.6.25. I've made some cosmetic/description changes and added a  
> "FORWARD" option that puts LVS into INPUT *and* FORWARD hooks, now the  
> options are: INPUT, FORWARD and PREROUTING. I think that all of these  
> have pros and cons, the user should choose...

Absolutely. And thanks - this is brilliant, I feel it'll give LVS some
more momentum.

> Absolutely, what do you think about creating a proc file that allows  
> to switch at runtime? This way at compile time the user/distribution  
> can choose the default behaviour and the user could change it in /proc/ 
> sys/net/vs/input_method. If you all agree i'll try to find some to  
> implement it.

+1 (and more) from me. The ability to make this sort of change without
rebooting will be *amazing*. Think of the power - a management interface
allowing changes on the fly, with (maybe...?) no interruption to
service. Brilliant.

Thanks again (from a user, rather than developer!)

Graeme

