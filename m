From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/24] netfilter: Remove unnecessary OOM logging messages
Date: Tue, 30 Aug 2011 14:46:34 +0200
Message-ID: <4E5CDBAA.6040001@trash.net>
References: <cover.1314650069.git.joe@perches.com> <13c1c12486cae409dfa5254b1435e660f2b17e05.1314650069.git.joe@perches.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <13c1c12486cae409dfa5254b1435e660f2b17e05.1314650069.git.joe@perches.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joe Perches <joe@perches.com>
Cc: Bart De Schuymer <bart.de.schuymer@pandora.be>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Stephen Hemminger <shemminger@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On 29.08.2011 23:17, Joe Perches wrote:
> Removing unnecessary messages saves code and text.
> 
> Site specific OOM messages are duplications of a generic MM
> out of memory message and aren't really useful, so just
> delete them.

Looks good to me. Do you want me to apply this patch or are you
intending to have the entire series go through Dave?
