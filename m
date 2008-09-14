From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sun, 14 Sep 2008 12:39:29 +0200
Message-ID: <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
	 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
	 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
	 <Pine.LNX.4.64.0809131835001.12375@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221388772; bh=6PtULP7skDoIV69xIxsfHMoK0Mc=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=YvudK5hOEmpF3WtsguFPFkZtINIOM1Hv
	VnSkxmXjCIVdAvHemtBjXO+Zg1SU3c9NvxAUEYfaYykLkjKqDTfVLA==
In-Reply-To: <Pine.LNX.4.64.0809131835001.12375@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sun, Sep 14, 2008 at 3:37 AM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> On Sun, 14 Sep 2008, Julius Volz wrote:
>
>> So maybe it would already work? ;)
>
> No. Some highly motivated people tried doing SNAT on OUTPUT in an attempt to
> do F5-SNAT and it didn't work. This lead to the write up in
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html#F5_snat
>
> which brings us to where we are now.

Thanks for the info! Right, I even said myself in the previous reply
that ip_vs_postrouting() stops further processing in the POSTROUTING
chain, so it never reaches netfilter NAT code.

I still think an in-IPVS SNAT would be nice anyways... don't know if
I'll find the time to hack on it soon, though.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
