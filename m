Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.75.44.102])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E2AAD3E8C74;
	Mon,  6 Jul 2026 08:23:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.75.44.102
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783326203; cv=none; b=ojF0sB+c8rCqAzZO+awRBH7jQ8qDmHEY8z/x6GD5jerN2o8dAUja7McRttTywBxvikzIXKbBdrh9kIurwP0MfztUKsw3L6woZlDz2sN7/Oy76emjy8tCDIf8YHqz5hsfoVT8i8wVLsIIyk3KFIYXpXPzsNvw2j5kTjaEuJ8jzf8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783326203; c=relaxed/simple;
	bh=D0zOeMBJpy829pf+i8TR/NJ+5p/Cs+0szyGzXSl1LqU=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=Th3gLgb85LqzPrrOFEPt6KNFcoOR+aP2ue+zJhfVeKFpn1I6FBThSQgy/HGE1qPpVpxkjDsPwLT+kfSqADYjek+cHnXRGOFpAKhQ3ScPIEseE5DGVDm/J/xdxGP2o7ei+vztNGM9TJACKMRXB1qMy86CZjENHeEQaJcJspenmaM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=WtBZDRBb; arc=none smtp.client-ip=13.75.44.102
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="WtBZDRBb"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:Content-Type:
	Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	Content-Transfer-Encoding:Message-Id:References:To; bh=d1EB3iLgS
	IEeytnOCuf1aEH2abzvN28uxXKkwxuXS+0=; b=WtBZDRBb9vAMNEY8o39qjEwY3
	O3vI6BxZJzyEKRb4IywjAfqKIYYzk0Ok9ymLkHCsYAzhUuBif9JkavnOGyK/F8gV
	TLW4gWOAmYfc4k2nA+jgbxf+V7RsXTTtS7xn4o6Lv6YM4cXJCqQay66D8bvc1IAn
	q+CXV1opCESaLjmjT0=
Received: from smtpclient.apple (unknown [101.5.13.242])
	by web3 (Coremail) with SMTP id ygQGZQAHVpO8ZUtqIAn9Ag--.29636S2;
	Mon, 06 Jul 2026 16:22:20 +0800 (CST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.700.81.1.8\))
Subject: Re: [PATCH nf] ipvs: skip IPv6 extension headers in SCTP state lookup
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <92783c87-7e6a-e90a-b2fc-e5d1332139e0@ssi.bg>
Date: Mon, 6 Jul 2026 16:22:10 +0800
Cc: netdev@vger.kernel.org,
 Simon Horman <horms@verge.net.au>,
 Pablo Neira Ayuso <pablo@netfilter.org>,
 Florian Westphal <fw@strlen.de>,
 Phil Sutter <phil@nwl.cc>,
 "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>,
 lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org,
 linux-kernel@vger.kernel.org,
 Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
 Ao Wang <wangao@seu.edu.cn>,
 Xuewei Feng <fengxw06@126.com>,
 Qi Li <qli01@tsinghua.edu.cn>,
 Ke Xu <xuke@tsinghua.edu.cn>,
 stable@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <87E04893-B2B2-485F-B242-9CACF2F176D6@mails.tsinghua.edu.cn>
References: <20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn>
 <92783c87-7e6a-e90a-b2fc-e5d1332139e0@ssi.bg>
To: Julian Anastasov <ja@ssi.bg>
X-Mailer: Apple Mail (2.3826.700.81.1.8)
X-CM-TRANSID:ygQGZQAHVpO8ZUtqIAn9Ag--.29636S2
X-Coremail-Antispam: 1UD129KBjvJXoW7uryDuF1UZF47Zr1xuF47twb_yoW8Xw48pF
	WkKryxWrZ7JrySqwnrAr4fXa48GF4DK347JF9YgFy2yFy5Kr1ftFWDK3yDKrW7ury5W34U
	ta4jv34kZayqyrDanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9m1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW7JVWDJwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8Jr0_Cr1UM28EF7xvwVC2z280aVAFwI0_GcCE3s1l
	84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2vYz4IE04k24VAvwVAKI4IrM2AIxVAIcx
	kEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8
	Ww4UJr1UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwACjI8F5VA0II8E6I
	AqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAaw2AFwI0_GFv_Wrylc2xS
	Y4AK67AK6r43MxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_GrWkJr1UJwCFx2
	IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v2
	6r106r1rMI8E67AF67kF1VAFwI0_GFv_WrylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67
	AKxVWUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IY
	s7xG6r1j6r1xMIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr
	0_Gr1UYxBIdaVFxhVjvjDU0xZFpf9x0JUpCJQUUUUU=
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgEAAWpLXY0RxQAAsn

Hi Julian,

Thanks for your review.

> On Jul 6, 2026, at 01:35, Julian Anastasov <ja@ssi.bg> wrote:
> 
> May be it is better starting from ip_vs_set_state()
> to provide new arg 'int iph_len/offset' (set to iph.len), down to
> state_transition(), sctp_state_transition() and set_sctp_state().
> Same for all protos. It should cost less stack and ipv6_find_hdr()
> calls and what matters most, correct iph context in case we
> have IP+ICMP+TCP (with just two ports or even with TCP flags)
> and are scheduling ICMP, i.e. not IP+TCP as usually.

I agree that the already parsed transport-header offset should be 
passed from ip_vs_set_state() down to the protocol state_transition() 
callbacks, instead of reparsing the skb in set_sctp_state(). We will 
send a v2 that does this for SCTP, TCP and the other IPVS protocols 
in one combined fix.

> But what I see is that ip_vs_in_icmp*() are missing
> the ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd) call just
> after ip_vs_in_stats() and before ip_vs_icmp_xmit() where
> we should provide ciph.len. That is why we don't reach the
> set_tcp_state() calls to set correct cp->state and timeout
> when scheduling related ICMP. So, this should be fixed too.

For the ICMP path, I agree that the missing ip_vs_set_state() call is
worth looking at, but using ICMP errors to drive the upper L4 state 
needs some care, because spoofed ICMP packets can match an 
existing embedded tuple before the endpoint TCP/SCTP stack 
performs its own validation. Maybe this change needs further
discussion?

Thanks,
Yizhou

