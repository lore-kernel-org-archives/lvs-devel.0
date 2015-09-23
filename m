From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH next 02/84] ipvs: Don't use current in proc_do_defense_mode
Date: Tue, 22 Sep 2015 20:53:30 -0500
Message-ID: <87oagtc351.fsf@x220.int.ebiederm.org>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
	<1442858581-15869-2-git-send-email-ebiederm@xmission.com>
	<20150923010648.GC17817@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150923010648.GC17817@verge.net.au> (Simon Horman's message of
	"Wed, 23 Sep 2015 10:06:48 +0900")
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Simon Horman <horms@verge.net.au> writes:

> On Mon, Sep 21, 2015 at 01:01:39PM -0500, Eric W. Biederman wrote:
>> Instead store ipvs in extra2 so that proc_do_defense_mode can easily
>> find the ipvs that it's value is associated with.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> I am wondering if this fix should be included in v4.3 and stable.
> Can the problem occur in practice?

I believe a lookup in one network namespace followed by write in another
network namespace would do it.  So I think it would take so pretty
deliberate and more or less peculiar actions to make it happen.

I don't know how important the update_defense_level call is or how bad
it is if it does not run in a network namespace .

Eric
