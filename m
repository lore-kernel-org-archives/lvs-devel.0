Received: from mail.netfilter.org (mail.netfilter.org [217.70.188.207])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 52809152E13;
	Thu, 25 Apr 2024 20:50:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.188.207
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1714078219; cv=none; b=jRIZLt5yxZ2jyHlLQ0WLnJBuuX3h7iDl3FZqwHQmDbG3vy8v2esLYIEYCXDTHAc9JNK5HIxF9oqHR3OqnC+Of9dHI3JjwPoAg/qwwunp3rNgHY/o7gCKFJRZp6yP9JQzha7MGEFnxBes19CWeuSEmvP44mMHRsZvQSglZJUcFzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1714078219; c=relaxed/simple;
	bh=J0qO3MJ0+uKqJInfu7cnRjx6k5KHUkRHuoq6Q5hbvcY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=GNEiKFyK2/8joMZYzy8nGWx9OihWFMMi5VPbtdkL4Nk7SI8dKOAbVDUy9tSLl27QjaUiZV/bDlQ9Y0I/G0b6hCtJDpYSt4QiHRbjpOqY3EF1p4NDSm+tGw65Ri4/t5CZIbbRERQW19zC/8aekAglRxKDj0OKtSk5wADuF5UPPyc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; arc=none smtp.client-ip=217.70.188.207
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Date: Thu, 25 Apr 2024 22:50:04 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Ismael Luceno <iluceno@suse.de>
Cc: linux-kernel@vger.kernel.org, Firo Yang <firo.yang@suse.com>,
	Andreas Taschner <andreas.taschner@suse.com>,
	Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.com>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH v3] ipvs: Fix checksumming on GSO of SCTP packets
Message-ID: <ZirB_Arz_4xKXG4s@calendula>
References: <20240425162842.23900-1-iluceno@suse.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20240425162842.23900-1-iluceno@suse.de>

Hi,

On Thu, Apr 25, 2024 at 06:28:40PM +0200, Ismael Luceno wrote:
> It was observed in the wild that pairs of consecutive packets would leave
> the IPVS with the same wrong checksum, and the issue only went away when
> disabling GSO.
> 
> IPVS needs to avoid computing the SCTP checksum when using GSO.

This patch went already upstream.

It was no clear to me that a v3 was needed.

You will have to post a follow up.
