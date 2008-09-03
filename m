From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv2 RFC 13/25] IPVS: Add IPv6 support to xmit() support functions
Date: Wed, 3 Sep 2008 10:43:13 +0200
Message-ID: <f4845fc0809030143k8126654k7d1c8e3d4c5d28a9@mail.gmail.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
	 <1220273782-19901-14-git-send-email-juliusv@google.com>
	 <20080902222814.GA6035@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220431397; bh=9auqIHTuHylrTbAWUg6tE73wYDc=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=nUwVPNJgvLbVWzxvGR+GQo9XVIbJlrT/
	66ivMCTWOymXkStyBK9xqZ3ScHIAZLZh9Db2RedrFvbuGCtgz81Www==
In-Reply-To: <20080902222814.GA6035@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Sep 3, 2008 at 12:28 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 01, 2008 at 02:56:10PM +0200, Julius Volz wrote:
>> Add IPv6 support to IP_VS_XMIT() and to the xmit routing cache, introducing
>> a new function __ip_vs_get_out_rt_v6().
>
> Hi,
>
> sorry, I missed this one yesteray. Could you run checkpatch.pl over
> this one also?

Yes, already cleaned up in the latest posted version (I ran
checkpatch.pl over all patches yesterday).

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
