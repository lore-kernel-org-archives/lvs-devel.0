From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net 0/2] netfilter: ipvs: some fixes in sctp_conn_schedule
Date: Mon, 28 Aug 2017 18:17:32 +0200
Message-ID: <20170828161732.GA13738@salvia>
References: <cover.1503207076.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1503207076.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xin Long <lucien.xin@gmail.com>
Cc: netfilter-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

On Sun, Aug 20, 2017 at 01:38:06PM +0800, Xin Long wrote:
> Patch 1/2 fixes the regression introduced by commit 5e26b1b3abce.
> Patch 2/2 makes ipvs not create conn for sctp ABORT packet.

Will wait for Julian and Simon to tell me what I should do with this.

Thanks!
