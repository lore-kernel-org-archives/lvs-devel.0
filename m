From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipvs: fix synchronization on connection close
Date: Mon, 14 Dec 2009 16:39:32 +0100
Message-ID: <4B265C34.6070205@trash.net>
References: <1260434502-14166-1-git-send-email-dfeng@redhat.com> <20091211033542.GA28136@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20091211033542.GA28136@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Xiaotian Feng <dfeng@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>

Simon Horman wrote:
> On Thu, Dec 10, 2009 at 04:41:42PM +0800, Xiaotian Feng wrote:
>> commit 9d3a0de makes slaves expire as they would do on the master
>> with much shorter timeouts. But it introduces another problem:
>> When we close a connection, on master server the connection became
>> CLOSE_WAIT/TIME_WAIT, it was synced to slaves, but if master is
>> finished within it's timeouts (CLOSE), it will not be synced to
>> slaves. Then slaves will be kept on CLOSE_WAIT/TIME_WAIT until
>> timeout reaches. Thus we should also sync with CLOSE.
>>
>> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
>> Cc: Wensong Zhang <wensong@linux-vs.org>
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Julian Anastasov <ja@ssi.bg>
>> Cc: David S. Miller <davem@davemloft.net>
> 
> This seems reasonable to me.
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.

