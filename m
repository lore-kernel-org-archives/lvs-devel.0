From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT PULL net-next-2.6] IPVS
Date: Thu, 16 Jun 2011 17:05:30 +0200
Message-ID: <4DFA1BBA.2090002@trash.net>
References: <1308095001-21002-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1308095001-21002-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>

On 15.06.2011 01:43, Simon Horman wrote:
> Hi Patrick, Hi Pablo,
> 
> please consider pulling
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next-2.6.git
> master
> 
> It includes four clean-ups by Hans
> and an enhancement of the FTP helper by Julian.
> 
> I have based the pull request on next-2.6 as
> nf-next-2.6 seems to be a little old. Please let me
> know if a different base would suit you better.
> 
> Hans Schillstrom (4):
>       IPVS remove unused var from migration to netns
>       IPVS: rename of netns init and cleanup functions.
>       IPVS: labels at pos 0
>       IPVS: remove unused init and cleanup functions.
> 
> Julian Anastasov (1):
>       ipvs: support more FTP PASV responses
> 

Pulled, thanks Simon.
