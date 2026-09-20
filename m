Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 922B9445ADD;
	Sun, 20 Sep 2026 14:10:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789913409; cv=none; b=DtT8MENymkSBrwHOuc/fzsvDvT3KoQpeqlr6F9+H7Jf9gVk9/XKFA6rm94qcljn/89D1PejenazJCn9poHCE2u0V4rzG7nYB8gWTHnFDevTZ/cT5aKcnSGDL7kpDa5Gupx7bm0dIiGRLEsuG2R7VNcTtV8uN5QPzG4uu5pmebjo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789913409; c=relaxed/simple;
	bh=RAwpRinokFbmsWfbjOhUYu9E7xo792Rc6rShwectdbs=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=VFrQnwG7trG+f0se/expEL8Mp6jhlqGsRSz4e3hSCn9n4WWi7J4DF55FXqTOHfH+9J0XYGaT+D+f8W046uQMEhmCTAPl/20L5B4KsW/gKPW0NZRc8pPvwo943F+styB3YJbTp203qUBoJRB8Ix+K4iXGfhLtvtQPkPFoCTdkw0E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=oMxdndPX; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="oMxdndPX"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 889CE213A9;
	Sun, 20 Sep 2026 17:09:55 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=0kSGxOsT2kMBxUhaJYvgYhP29t1aRmGrsHWWAOcTsMA=; b=oMxdndPXIWEj
	uny011REFFTwbO4RKExNtkm9vFxiIz0DUBSN8ux54TR5CxlxP60qKfbv2yJWOOBa
	dU1Co+kWLrIZZPbrG+pf5vny9AmlmXcZxHgv/EwpQllxCqpcFDFL+cYBcUcmqZlA
	CTS3rMvBqTCq9fhzjYwsm4pyf2vyDkfFBJc7cnU6C+YUbE+SMyvA6hAllkOZHWNE
	Bm7xqtiUPdim1pEHdKXmBFMl+uIV2iOoRo+0lhC2JlloZ2pRlklsk+BG+tJORr1u
	YweoJXtCKsoA6bMdanX6HlvfLH8MjGrQyi11ZJhuXQZLLF2ekHHzikrKBqFW13Hd
	0es8t9l10VVEgXe5NAaG/OGzopjsim3zh1EbDWmk7a1lslZOyEn5KHP9f7sIMqKC
	xbXjbGW0zXw2mQplO3rIU7adDypmpt8T5ijl1RKuLOsDoO8Nxv/C9RJlOifTEfJg
	dekKCPFZAy9A1mYsRIONHs19lhPZhlilwezNS3ZwhUXNLW/Gl2fOKeswinaULZqx
	eYKLYiO5PTZ+TAdQ4wDtpZqM3n8BpX83wZSS1D+8sc+Jd6Tyx6IH8yWne1/vbjt4
	XrSRMIdB4yUJAn4DVfVTcxwho299tKI1S+KOEMlNb3l0E7ZOoAToBvLBC2Svr0Kh
	9JqY/WQJgiyCny/Q7DfF06Ib/o2d7LE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 20 Sep 2026 17:09:55 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9B1C660851;
	Sun, 20 Sep 2026 17:09:57 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68KE9qxt037118;
	Sun, 20 Sep 2026 17:09:54 +0300
Date: Sun, 20 Sep 2026 17:09:52 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Jiayuan Chen <jiayuan.chen@linux.dev>
cc: Yuan Tan <yuant@nebusec.ai>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, darby.payne@gmail.com,
        zzyy19904204639@163.com, Ren Wei <weir@nebusec.ai>
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
In-Reply-To: <b2a1cc29-74ef-48e4-bd41-283279f2f670@linux.dev>
Message-ID: <7ab0cfc7-96c8-eaea-f560-fc18ddf1201a@ssi.bg>
References: <cover.1789117690.git.zzyy19904204639@163.com> <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg> <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev> <bfdbe9ba-f213-64e9-668d-e951aa0c2863@ssi.bg> <f04216a2-263a-4e2d-9641-5be0fe4c766f@nebusec.ai>
 <d000dd3a-0e8e-5b04-4642-fc1be0ffedaf@ssi.bg> <b2a1cc29-74ef-48e4-bd41-283279f2f670@linux.dev>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-792102681-1789913396=:34383"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-792102681-1789913396=:34383
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sun, 20 Sep 2026, Jiayuan Chen wrote:

> On 9/20/26 9:19 PM, Julian Anastasov wrote:
> > 
> > 2. I can post my change after adding a proper commit
> > message (Co-developed-by, etc), then it can be attached as
> > 1/1 to your modified 0/1 problem report
> >
> >  I'll wait Jiayuan's decision.
> 
> 
> Feel free to take any further action  :)
> 
> I just gave my idea and hope anyone can be inspired by this.

	Thanks! Then I'll post single patch soon...

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-792102681-1789913396=:34383--

