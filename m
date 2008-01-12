From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING)
Date: Fri, 11 Jan 2008 17:44:51 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801111738220.9237@wm7d.net>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
 <Pine.LNX.4.64.0801100432180.28592@wm7d.net> <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com>
 <20080111041426.GF13135@verge.net.au> <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <38B8D1A9-BBDB-459A-BF02-E77B852E03B8@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

On Sat, 12 Jan 2008, Raphael Vallazza wrote:

> I've attached patches for net-2.6 (works on 2.6.24-2.6.22) and net-2.6.25. 
> I've made some cosmetic/description changes and added a "FORWARD" option that 
> puts LVS into INPUT *and* FORWARD hooks, now the options are: INPUT, FORWARD 
> and PREROUTING. I think that all of these have pros and cons, the user should 
> choose...

I'm absolutely stunned. We've been wanting this for quite a 
while and no-one has had time to do it. I could see no way 
it would ever arrive and had kissed it goodbye. Thanks very 
much

I don't know how much info ip_vs is sending to /proc 
nowadays (is /proc supposed to go away still? It looks very 
alive to me and I use it for rrdtool at work.)

If all the lvs stats aren't being shipped to /proc, is it 
possible to do so?

How much work is involved in making the standard ip_vs 
active/active?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
