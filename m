From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/16] net: Pass net through the output path v2
Date: Thu, 08 Oct 2015 04:27:43 -0700 (PDT)
Message-ID: <20151008.042743.1639317207403403583.davem@davemloft.net>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
	<878u7fesrg.fsf_-_@x220.int.ebiederm.org>
	<87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, nicolas.dichtel@6wind.com, lvs-devel@vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 07 Oct 2015 16:46:49 -0500

> This is the next installment of my work to pass struct net through the
> output path so the code does not need to guess how to figure out which
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.

Seires applied, thanks Eric.
