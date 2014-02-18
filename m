From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: Regression in pmtud lvs-nat with ipv6 since at least 3.10
Date: Tue, 18 Feb 2014 11:05:33 +0100
Message-ID: <20140218100533.GE18029@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi Julian,

On Mon, Feb 17, 2014 at 11:34:43PM +0200, Julian Anastasov wrote:
> 	May be ipv6_find_hdr() can not be called with
> exact protocol number, the offset is not updated,
> it remains 0 and -ENOENT is returned. As result,
> icmp_offset is not changed to 40.

I was thinking along that line too, since sizeof(struct icmp6hdr)
would exactly skip that part, hence pointing ciph at the
second half of the first ip address.
I try to make a test setup, since the real lvs servers are
actually production ;-).
But I can live with a little downtime on my desktop 8-D.

Regards,
Ard
