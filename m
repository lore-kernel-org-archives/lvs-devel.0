From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Wed, 26 Nov 2008 15:27:48 -0800 (PST)
Message-ID: <20081126.152748.244331470.davem@davemloft.net>
References: <1227706578-5449-1-git-send-email-catab@embedromix.ro>
	<Pine.LNX.4.64.0811260636100.26650@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811260636100.26650@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: jmack@wm7d.net
Cc: catab@embedromix.ro, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: Joseph Mack NA3T <jmack@wm7d.net>
Date: Wed, 26 Nov 2008 06:40:02 -0800 (PST)

> On Wed, 26 Nov 2008, Catalin(ux) M. BOIE wrote:
> 
> > I was very frustrated about the fact that I have to recompile the kernel
> > to change the hash size. So, I created this patch.
> 
> thanks for sending us the code.
> 
> Why do you need to change the hash size? We really don't recommend anyone do this under normal circumstances

In any event, this should be dynamically sized at run time.
