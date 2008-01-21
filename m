From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING)
Date: Mon, 21 Jan 2008 11:48:20 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0801211134530.2943@u.domain.uli>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
 <Pine.LNX.4.58.0801182328060.2854@u.domain.uli> <59D1E185-12C3-43E5-AD63-F56583E4BBB3@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <59D1E185-12C3-43E5-AD63-F56583E4BBB3@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sun, 20 Jan 2008, Raphael Vallazza wrote:

> The only solution i've found was the PREROUTING one, this way DNAT can  
> be done on the realserver (either Node1 or Node2) and it works on both  
> nodes.
> 
> I hope the example is clear.

	Yes, thanks. I now see the problem with LVS-LOCALNODE for squids.

Regards

--
Julian Anastasov <ja@ssi.bg>
