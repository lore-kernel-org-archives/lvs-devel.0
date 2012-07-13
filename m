From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: generalize app registration in netns
Date: Fri, 13 Jul 2012 11:59:32 +0900
Message-ID: <20120713025932.GC19755@verge.net.au>
References: <1341966327-16606-1-git-send-email-horms@verge.net.au>
 <1341966327-16606-3-git-send-email-horms@verge.net.au>
 <20120712162209.GA21904@1984>
 <alpine.LFD.2.00.1207122304190.1831@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1207122304190.1831@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Thu, Jul 12, 2012 at 11:06:20PM +0300, Julian Anastasov wrote:
> 
> 	Get rid of the ftp_app pointer and allow applications
> to be registered without adding fields in the netns_ipvs structure.
> 
> v2: fix coding style as suggested by Pablo Neira Ayuso <pablo@netfilter.org>

Thanks, I have (forcibly) pushed this into the ipvs-next tree in
place of v1.

I will want for consensus on the "ipvs: ip_vs_ftp depends on
nf_conntrack_ftp helper" change before sending a fresh
pull request to Pablo.

