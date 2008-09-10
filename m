From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Wed, 10 Sep 2008 19:30:52 +0200
Message-ID: <f4845fc0809101030u2bd4dec4jb478ecc65240ea74@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <20080908234028.GF13048@verge.net.au>
	 <f4845fc0809090230h1cbc01ev45c6ab4bdba61955@mail.gmail.com>
	 <20080909113131.GA3605@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221067855; bh=LCnGcgngqafe2VkoB6YnGzMkYKQ=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=mEAuOT4jOtpp+6TtubUgtadomQGleCDZ
	SgryM4KYF8xpBUf6HjfA47X9Ms3/IHgKEXjgQXEiynLQ8ublnsGhcQ==
In-Reply-To: <20080909113131.GA3605@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Vince Busam <vbusam@google.com>, wensong@linux-vs.org

On Tue, Sep 9, 2008 at 1:31 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 09, 2008 at 11:30:29AM +0200, Julius Volz wrote:
>> Great, thanks! I have tested TCP+UDP, local+remote clients, v4+v6,
>> NAT+DSR+TUN in all combinations that are expected to be working and
>> found no problems.
>
> Thanks once again for your testing. I'll send a pull request to Dave in
> the morning.

Thanks very much!

(CC: Wensong)
I guess it would make sense to start hosting the new ipvsadm version
somewhere on http://www.linuxvirtualserver.org/ soon. It could still
be marked as unstable and saying, "If you intend to use the
experimental IPv6 support for IPVS introduced in kernel 2.6.XX, you
will need this new version of ipvsadm: ...". Also, we can then point
to it in the Kconfig help text in CONFIG_IP_VS_IPV6. What do you
think?

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
