From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6 addresses.
Date: Thu, 12 Jun 2008 11:47:40 +0200
Message-ID: <f4845fc0806120247j32ebe3c7s55e247a35d0d93e7@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <1213204329-10973-3-git-send-email-juliusv@google.com>
	 <485081E8.80102@hp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213264062; bh=J00zxR0sJ+aiRs7Llh81jlSF4/w=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=fn4B3ogc7i04H//XNCdDSDRkCf608ZlT
	hh9Gl2XaVN4nAlReTpkXOwNCq1sNtXLHUuKoeu8gP96uyG0iaoP+Zw==
In-Reply-To: <485081E8.80102@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Brian Haley <brian.haley@hp.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Thu, Jun 12, 2008 at 3:54 AM, Brian Haley <brian.haley@hp.com> wrote:
> You need to use ipv6_addr_copy() with IPv6 addresses.  Some of your other
> patches have this same problem, I found some of them...

Thanks for spotting this, I will convert it in the next version!

Julius

-- 
Google Switzerland GmbH
