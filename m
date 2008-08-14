From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv3 0/2] IPVS: Add Generic Netlink configuration interface
Date: Thu, 14 Aug 2008 11:34:13 +0200
Message-ID: <f4845fc0808140234v77b1e00ega7b80044877ce7b1@mail.gmail.com>
References: <1218120219-1117-1-git-send-email-juliusv@google.com>
	 <20080808022607.GB6094@verge.net.au>
	 <20080808120642.GB32458@google.com>
	 <20080809142331.GA3497@verge.net.au>
	 <f4845fc0808130900o550511dn2ec425bb2c911738@mail.gmail.com>
	 <20080813230927.GB10749@verge.net.au>
	 <20080814041240.GA778@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218706455; bh=gNe00d+KTq3SHtNqB51VWWANr/I=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=IQidrKFUYmBGYoE0pK/6G4jq2xnDwyxP
	EYmPtjcOQ54u2L35KrxiqbBLLPbfyaxavUMUE/whn8QX/JPsf9/MXw==
In-Reply-To: <20080814041240.GA778@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Thu, Aug 14, 2008 at 6:12 AM, Simon Horman <horms@verge.net.au> wrote:
> I tried to stress this code a bit more and nothing fell off.

Good, thanks!

> I'm pretty happy with them, though Sven's comment about error checking
> needs attention.

Yes, I just posted a fixed version.

Julius

-- 
Google Switzerland GmbH
