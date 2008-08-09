From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv3 0/2] IPVS: Add Generic Netlink configuration interface
Date: Sat, 9 Aug 2008 21:57:57 +0200
Message-ID: <f4845fc0808091257m63bb8b70i3eb9782e73d0e9b2@mail.gmail.com>
References: <1218120219-1117-1-git-send-email-juliusv@google.com>
	 <20080808022607.GB6094@verge.net.au>
	 <20080808120642.GB32458@google.com>
	 <20080809142331.GA3497@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218311880; bh=an6Es4ru9Khc3OeaGo5FPhSiZaQ=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=ZTFAgt3feaAwRKdRXnPKoBQw06PSbK0u
	JuHt+MmpCwfFODhwSL3sl1JFdKhNvs20VXx0GbfVCBmCDMGYVj91tw==
In-Reply-To: <20080809142331.GA3497@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Sat, Aug 9, 2008 at 4:23 PM, Simon Horman <horms@verge.net.au> wrote:
> your latest patch does resolve the problem that I was seeing
> with ipvsadm-1.25-nl-2. ipvsadm-1.25-nl-3 also works :-)

Nice!

> I'd like to try and stress it out a bit more.
> I will try and get to that tomorrow or on Monday.

Great, thank you!

Julius

-- 
Google Switzerland GmbH
