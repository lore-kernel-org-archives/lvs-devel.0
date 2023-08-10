From: Kuniyuki Iwashima <kuniyu@amazon.com>
Subject: Re: Race over table->data in proc_do_sync_threshold()
Date: Wed, 9 Aug 2023 19:27:34 -0700
Message-ID: <20230810022734.47246-1-kuniyu@amazon.com>
References: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1691634489; x=1723170489;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=bzEek1zgt1wND7V2uHTMP/IFQxtrm8y1bob9SqKo9zI=;
  b=KaHzKPDBA3kBwQqdbVZf12BH8MpzsD74JdEC7brZTSu//iFSrFFgQBW8
   RNc6YMSpIUYhOtId+9vp3Q/UaKaSZll2tuoFBOnsr9r2pLwZ+gO4K8jIp
   PC93U3GbFLJkkhKSeFIZ5w/WKKJZ0ODjYLNs3VBMDskeSGAM/uFm5nTSc
   Y=;
In-Reply-To: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: sishuai.system@gmail.com
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kuniyu@amazon.com

From: Sishuai Gong <sishuai.system@gmail.com>
Date: Wed, 9 Aug 2023 20:30:37 -0400
> Hi,
> 
> We observed races over (struct ctl_table *) table->data when two threads
> are running proc_do_sync_threshold() in parallel, as shown below:
> 
> Thread-1			Thread-2
> memcpy(val, valp, sizeof(val)); memcpy(valp, val, sizeof(val));
> 
> This race probably would mess up table->data. Is it better to add a lock?

Yes, we should acquire mutex/seqlock etc.
