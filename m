From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH 1/4] treewide: convert ISO_8859-1 text comments to utf-8
Date: Tue, 24 Jul 2018 14:02:30 -0700
Message-ID: <d5cf9579-5d61-dafc-5109-b86bfca07dce@infradead.org>
References: <20180724111600.4158975-1-arnd@arndb.de>
 <20180724140010.e24a9964fd340afe2d98a994@linux-foundation.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
        In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
        :Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
        Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
        List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
        bh=564sf8dJM7q6oLia5o1lXvXCGX460MgoMxzBV52TK0Q=; b=HrZFyFH9jJ27JphCrMkNaay2Dl
        hCRG1JOH1scJYL1xTw9+XzMkCkVcENcsVKZwpfqBngaSVJk3IdNAi9M+6ICq4C4z6n859BKGWug8k
        in5hTunYNxIN0WZLqPU10X3U8BhmFuDoRnTFGa6JiMpvkEzUWZgnl9bhkiPmcedDIdAP0GvWY1voV
        UHxRAdhJFy5x/FhgLE45B804eS9ZNCuaO4/gCk3qfKgLro+8GnW+j/hudAGgD+HQvmFhe2W2WJavk
        VJtjpXvbjQSicEt20oVA4nQMsi97UAgzsVynFzimHJrtUZdgSSu/bfWj929gfbAFLd08CT/OiTFSC
      
In-Reply-To: <20180724140010.e24a9964fd340afe2d98a994@linux-foundation.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>
Cc: Joe Perches <joe@perches.com>, Samuel Ortiz <sameo@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Rob Herring <robh+dt@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Cameron <jic23@kernel.org>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-iio@vger.kernel.org, linux-pm@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On 07/24/2018 02:00 PM, Andrew Morton wrote:
> On Tue, 24 Jul 2018 13:13:25 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
> 
>> Almost all files in the kernel are either plain text or UTF-8
>> encoded. A couple however are ISO_8859-1, usually just a few
>> characters in a C comments, for historic reasons.
>>
>> This converts them all to UTF-8 for consistency.
> 
> Was "consistency" the only rationale?  The discussion is now outside my
> memory horizon but I thought there were other reasons.

kconfig tools prefer ASCII or utf-8.

email tools probably likewise.

user sanity?

> Will we be getting a checkpatch rule to keep things this way?



-- 
~Randy
