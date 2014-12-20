From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: seqadj ext fix in ipvs for 3.12 stable
Date: Sat, 20 Dec 2014 14:14:39 +0100
Message-ID: <20141220131439.GA4785@salvia>
References: <alpine.LFD.2.11.1412182244420.2055@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1412182244420.2055@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>

On Thu, Dec 18, 2014 at 10:56:26PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> 	Pablo, please consider commit b25adce16064
> ("ipvs: correct usage/allocation of seqadj ext in ipvs") for
> inclusion in 3.12 stable. Florian Wiessner tested it
> on 3.12.33 to fix the crash in nf_ct_seqadj_set.
> 
> 3.10 and below do not need it. It is part of 3.13
> but seqadj code that caused the problem is in 3.12.
> 
> Reference: http://marc.info/?t=141761860700001&r=1&w=2

Enqueue to -stable 3.12.x. Thanks Julian.
