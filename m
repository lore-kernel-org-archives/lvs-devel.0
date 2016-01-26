From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Remove noisy debug print from ip_vs_del_service
Date: Tue, 26 Jan 2016 10:25:19 +0900
Message-ID: <20160126012519.GM26945@verge.net.au>
References: <1453770745-12788-1-git-send-email-scientist@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1453771522; bh=ggVeN8IsfD6juFsVFxFLDpY7yh1EEPAaf0AF3lAiOQA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Tq3/QADKdaEgzAMG64Fap1vc2/s14L3Eu+bTaX52Fb3T3X8JkIZetgWjsD/A9E+PH
	 2HDeztr+/ihg3RNj9xGkMAmwSEZMdTJ/IatuMuc742sCU2ZUfioCOvD38u9uq6CZzF
	 qpDgKweMEJNX5Z6KavJpW8TY/koMSVcGzvhi4SSs=
Content-Disposition: inline
In-Reply-To: <1453770745-12788-1-git-send-email-scientist@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yannick Brosseau <scientist@fb.com>
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org

On Mon, Jan 25, 2016 at 05:12:25PM -0800, Yannick Brosseau wrote:
> This have been there for a long time, but does not seem to add value

Thanks, applied.
