Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7922216063E;
	Thu, 29 Feb 2024 18:04:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709229870; cv=none; b=SoupiKvyHPnEj6pW9B6LthGCG4pZGBH0crrkS2oNBrICFCTrwfbNR9kFj04jN7fQaMT7s9GVMSkSjLrc1Hj/Nvx7uTqGcXSTbT+nhPbNMS1lwDbjJe3GviL3vs7JF+ArTdIsPGMWGN+UQvFnh1Fo8HZ6fT1/QgqKJ0MRcjhmhCk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709229870; c=relaxed/simple;
	bh=uVrQYwDFWZ6EydZnz4v2l2ah0q7EbD1NZQs4iNdMifA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=uFqcREeNiCkCheuLvLhYLf1AZ9IaXyBvA/wq7N7ETrRafRejAOXga/qKuzBU4HUDNqF8gKacjdkTUnXdLHGRoxxtq77oXTzE0lBh9gwbPzb8i9etyIFowGyWYOA/ZJKSahnCRmCJwBUltTXF0R+e64FGyqVe7g+FPdCmv1+PzR0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=J06O+bYi; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="J06O+bYi"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 85FCF351EE;
	Thu, 29 Feb 2024 19:56:12 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS id 6E667351EA;
	Thu, 29 Feb 2024 19:56:12 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id E5E623C07CB;
	Thu, 29 Feb 2024 19:56:09 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1709229370; bh=uVrQYwDFWZ6EydZnz4v2l2ah0q7EbD1NZQs4iNdMifA=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=J06O+bYia73zVrknwqrja9hBRrxp0sLdKEq6cS74DK95OeSo2c97bNmUUW4YEGGK9
	 A9L+TPBWkAHB8bUc+DBbBjPXRsTGbpIjfNqajF2tWG3SnG1Pf/u1O5s/G3W6vm7Knx
	 EhQrPy7kjtowa8epuiowa/cp3Lc7zdg6YxwRmUFE=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 41THu1Wp094200;
	Thu, 29 Feb 2024 19:56:01 +0200
Date: Thu, 29 Feb 2024 19:56:01 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Terin Stock <terin@cloudflare.com>, horms@verge.net.au,
        kadlec@netfilter.org, fw@strlen.de, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, kernel-team@cloudflare.com
Subject: Re: [PATCH] ipvs: generic netlink multicast event group
In-Reply-To: <ZeCy39VOYVB_r5bP@calendula>
Message-ID: <ca382b0a-737c-e903-270b-7ec98549ecae@ssi.bg>
References: <20240205192828.187494-1-terin@cloudflare.com> <51c680c7-660a-329f-8c55-31b91c8357fd@ssi.bg> <ZeCy39VOYVB_r5bP@calendula>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 29 Feb 2024, Pablo Neira Ayuso wrote:

> On Wed, Feb 07, 2024 at 06:44:48PM +0200, Julian Anastasov wrote:
> [...]
> > 	I also worry that such events slowdown the configuration
> > process for setups with many rules which do not use listeners.
> > Should we enable it with some sysctl var? Currently, many CPU cycles are 
> > spent before we notice that there are no listeners.
> 
> There is netlink_has_listeners(), IIRC there was a bit of missing work
> in genetlink to make this work?

	Looks like genl_has_listeners() should be sufficient...

Regards

--
Julian Anastasov <ja@ssi.bg>

