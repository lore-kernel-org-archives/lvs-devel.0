From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs-next] ipvs: count pre-established TCP states as
 active
Date: Mon, 13 Jun 2016 14:20:07 +0900
Message-ID: <20160613052007.GC11835@verge.net.au>
References: <20160603155650.292BEA0E60@unicorn.suse.cz>
 <alpine.LFD.2.11.1606121825110.2021@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1465795209; bh=0/I9k5i45MJO/r15rdNpaa22SPwNEF/pSmqOdyUkvkA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=i88U2kCzlO0MzPoLmP/xOWvsFSOFe8VtPs0EtPpqcZqinIKGjB+MRC0Xd1OXNuUcM
	 +m6RKLrsIsw6DLLxW4hkNXyZVR7slhvLDmb0SL0YTFBWck6OSW0+hjRHzWHsVqDc2N
	 EnWPcuogtViUAmVKeCdOgYI5aR8/+Ur/1xqwR5xQ=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1606121825110.2021@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Michal Kubecek <mkubecek@suse.cz>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>

On Sun, Jun 12, 2016 at 06:27:39PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 3 Jun 2016, Michal Kubecek wrote:
> 
> > Some users observed that "least connection" distribution algorithm doesn't
> > handle well bursts of TCP connections from reconnecting clients after
> > a node or network failure.
> > 
> > This is because the algorithm counts active connection as worth 256
> > inactive ones where for TCP, "active" only means TCP connections in
> > ESTABLISHED state. In case of a connection burst, new connections are
> > handled before previous ones have finished the three way handshaking so
> > that all are still counted as "inactive", i.e. cheap ones. The become
> > "active" quickly but at that time, all of them are already assigned to one
> > real server (or few), resulting in highly unbalanced distribution.
> > 
> > Address this by counting the "pre-established" states as "active".
> > 
> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply!

Thanks, done.
