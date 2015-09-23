From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH next 02/84] ipvs: Don't use current in
 proc_do_defense_mode
Date: Wed, 23 Sep 2015 10:06:48 +0900
Message-ID: <20150923010648.GC17817@verge.net.au>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
 <1442858581-15869-2-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442858581-15869-2-git-send-email-ebiederm@xmission.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

On Mon, Sep 21, 2015 at 01:01:39PM -0500, Eric W. Biederman wrote:
> Instead store ipvs in extra2 so that proc_do_defense_mode can easily
> find the ipvs that it's value is associated with.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

I am wondering if this fix should be included in v4.3 and stable.
Can the problem occur in practice?
