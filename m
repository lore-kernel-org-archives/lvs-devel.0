From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [PATCH] Runtime interception method switch
Date: Wed, 16 Jan 2008 12:16:19 +0100
Message-ID: <478DE783.5070203@tis.icnet.pl>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com> <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au> <Pine.LNX.4.64.0801150501120.22826@wm7d.net> <20080116075044.GA19249@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080116075044.GA19249@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: 
Cc: LVS Devel <lvs-devel@vger.kernel.org>

Simon Horman wrote:
> On Tue, Jan 15, 2008 at 05:13:14AM -0800, Joseph Mack NA3T wrote:
>> What side effects might there be? Are they worse than not being able to 
>> NAT packets emerging from a director?
> 
> I'm not sure, and thats what concerns me.
> 
> For starters could we clarify that the patch in question is the
> following one by Janusz Krzysztofik?
> 
> Also can I clarify that the aim is to be able to SNAT LVS-DR
> connections ...

Hi,

I can confirm what I have already said before: this patch works for me 
(now for over two years) without any unexpected side effects. The only 
side effect I can see is that all LVS-DR incoming packets go through 
conntrack, even if you do not intend to SNAT them. That could present 
excessive load on ancient hardware, but one can just unload conntrack 
modules, or turn connection tracking off for specific traffic with 
PREROUTING raw hook rules.
However, I think this patch should be considered, if at all, as a 
temporary solution.

Thanks,
Janusz

PS. I am still busy with a different project, but subscribed to lvs-devel.
