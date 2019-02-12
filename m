From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: Re: [PATCH net-next] ipvs: Use struct_size() helper
Date: Mon, 11 Feb 2019 19:47:28 -0600
Message-ID: <40215a8b-3b64-cf6c-c6cd-7d8d5dd971d3@embeddedor.com>
References: <20190208004456.GA15845@embeddedor>
 <20190208095648.la4ushbjxkqgqzb6@verge.net.au>
 <20190211234033.wwpygxamqwvsuxmv@salvia>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190211234033.wwpygxamqwvsuxmv@salvia>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org



On 2/11/19 5:40 PM, Pablo Neira Ayuso wrote:
> On Fri, Feb 08, 2019 at 10:56:48AM +0100, Simon Horman wrote:
>> On Thu, Feb 07, 2019 at 06:44:56PM -0600, Gustavo A. R. Silva wrote:
>>> One of the more common cases of allocation size calculations is finding
>>> the size of a structure that has a zero-sized array at the end, along
>>> with memory for some number of elements for that array. For example:
>>>
>>> struct foo {
>>>     int stuff;
>>>     struct boo entry[];
>>> };
>>>
>>> size = sizeof(struct foo) + count * sizeof(struct boo);
>>> instance = alloc(size, GFP_KERNEL)
>>>
>>> Instead of leaving these open-coded and prone to type mistakes, we can
>>> now use the new struct_size() helper:
>>>
>>> size = struct_size(instance, entry, count);
>>>
>>> This code was detected with the help of Coccinelle.
>>>
>>> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
>>
>> Acked-by: Simon Horman <horms+renesas@verge.net.au>
>>
>> Pablo, could you consider applying this?
> 
> Applied, thanks!
> 

Thank you both, Simon and Pablo.

--
Gustavo
