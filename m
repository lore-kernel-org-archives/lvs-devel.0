Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6344614601C;
	Wed, 12 Mar 2025 14:48:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741790933; cv=none; b=r++8pnKVd2UhzBv8ae0koYWCPjYJw77u858//pU9b1WrhKV7LaCF6k0nzlknMSoPZAFwY0OplTf/OYSxAs9UHa1T6txJNl8jTSRtfth8mGVrYxERMD0jh4FRbXxW3duyaRsHxFw7hcy/RCxWYNkfJrGaMhgVle70PSVRJlZq788=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741790933; c=relaxed/simple;
	bh=rhkReZw7ouylU250M0RZbXomCucOdddV3/DWLIwvQV8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Jc48fyOIJvrwESw+MdFuNdbZcy1wZ5e7LM1MgRPn5jjf0TCxNZRiEslgx0bSLFZr7U+JKOKW3b9vh815vk/IQscU8PtO8cq5gaj2ZsmybnOuwgEklShK76MHPBbryUrmf2oT/boxqGodi5Df++blY0c2nmq1YVcJ2Hyfeo+lg5E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=pKwSiXFL; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=haaOsYYi; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="pKwSiXFL";
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="haaOsYYi"
Received: by mail.netfilter.org (Postfix, from userid 109)
	id 9EC3D60288; Wed, 12 Mar 2025 15:48:49 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1741790929;
	bh=y+PELDLVlWxQuQQQUIVwHopabwrUkoFrP7Uybc+xikk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=pKwSiXFL1FVAnJDcDjsqs+JFmGuEpOVTtrfXgXpuNVGKGJ56rUQdkfNyx/DUHeuuC
	 Hp3UIuYh5QETVves9ZkRrSKPQVuqbAwHqKuHBJf8dKQOSzUQfajFwwJrDqDPlZeHGg
	 UXu8GUIFEYmw824qmcFA1X6BY+1SmShMX3GgDwtxBDR74AYjaGKzMX9KFVlt1s9+nE
	 3fT6NLGFnRHcODTkZ7NKu1rKr875AxrDx5PnpVNoRYYQlF5d3tsljlR637i5Gyc7Pu
	 u+ETn35swNxmOhaWzOtIQWa4tGm4tJAAjEOTE55fd8C9I92iwLNqgTVISvCUAuY5eD
	 GpP1vuTyKPZgA==
X-Spam-Level: 
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 32FA96026B;
	Wed, 12 Mar 2025 15:48:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1741790927;
	bh=y+PELDLVlWxQuQQQUIVwHopabwrUkoFrP7Uybc+xikk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=haaOsYYiszm5BNqkrBwcNDYbVafIv5yGwG9uJEQTPQ5yOWKwmNqMS4qzYYMlO3xuW
	 mrlBgS4dU+m7nLYmFdJaMZPzfNH+YjgrKT22ilJn5atLlF+BS/uTVZKfYXNbKtwJhC
	 9OP3O28FEq2+TSXOa25a50XgPQ96FZ06o/JUkOlCt323I30VzVDyE59z6mMDdZmQsr
	 RnMOI/IsubIFC4oseJd9zbWkGLoNoVlsoG1c18WxAod6+zDbvvAhcZplXOpVWiI4it
	 knpukeWvTHY0VX+AG5v3jkORntuCkQRUpH85UQP7dFgmwbEGIl5Q0p4jX0Jt7+3iFP
	 gS1pwrGKCE/WA==
Date: Wed, 12 Mar 2025 15:48:44 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Dan Carpenter <dan.carpenter@linaro.org>,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>,
	Simon Horman <horms@verge.net.au>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH v2 net] ipvs: prevent integer overflow in
 do_ip_vs_get_ctl()
Message-ID: <Z9GezONZJ_sDuwFy@calendula>
References: <1304e396-7249-4fb3-8337-0c2f88472693@stanley.mountain>
 <262d87d6-9620-eef4-3d36-93d9e0dc478c@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <262d87d6-9620-eef4-3d36-93d9e0dc478c@ssi.bg>

On Tue, Mar 11, 2025 at 07:50:44PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 10 Mar 2025, Dan Carpenter wrote:
> 
> > The get->num_services variable is an unsigned int which is controlled by
> > the user.  The struct_size() function ensures that the size calculation
> > does not overflow an unsigned long, however, we are saving the result to
> > an int so the calculation can overflow.
> > 
> > Both "len" and "get->num_services" come from the user.  This check is
> > just a sanity check to help the user and ensure they are using the API
> > correctly.  An integer overflow here is not a big deal.  This has no
> > security impact.
> > 
> > Save the result from struct_size() type size_t to fix this integer
> > overflow bug.
> > 
> > Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> > Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Pablo, you can apply it to the nf tree.

Done, thanks Julian.
