From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v1] ipvs: fix multiplicative hashing in sh/dh/lblc/lblcr algorithms
Date: Sun, 01 Apr 2018 12:16:10 +0200
Message-ID: <m3lge7dyfp.fsf@luffy.cx>
References: <20180331222838.32758-1-vincent@bernat.im>
        <alpine.LFD.2.20.1804011037200.1933@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=bernat.im; h=from:to:cc
        :subject:references:date:in-reply-to:message-id:mime-version
        :content-type; s=postfix; bh=izm7ot0nuvPrdaFeNFs6OYJQYoo=; b=Gm2
        dj74tztX52nBDxl1S1tse+lm0Xo4vp37EzaKomXS/YCyzd/nl7mWIbt78+hP18qr
        pvUpl2KevPfM77CWp/+3hM9fZYhcU/aMV3nvCPgdj8EHzim+L/N85IiYdA47X4u3
        8I23CMQOG/bwiDcZvGHrIs2qa9zPF/UdGbG+O7vY=
In-Reply-To: <alpine.LFD.2.20.1804011037200.1933@ja.home.ssi.bg> (Julian
        Anastasov's message of "Sun, 1 Apr 2018 11:11:08 +0300 (EEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

 =E2=9D=A6  1 avril 2018 11:11 +0300, Julian Anastasov <ja@ssi.bg>=C2=A0:

>> -	return (ntohl(addr_fold)*2654435761UL) & IP_VS_DH_TAB_MASK;
>> +	return ((ntohl(addr_fold)*2654435761U) >>
>> +		(32 - IP_VS_DH_TAB_BITS)) &
>> +		IP_VS_DH_TAB_MASK;
>
> 	Looks like the '& mask' part is not needed, still,
> it does not generate extra code. I see that other code uses
> hash_32(val, bits) from include/linux/hash.h but note that it
> used different ratio before Linux 4.7, in case someone backports
> this patch on old kernels. So, I don't have preference what should
> be used, may be return hash_32(ntohl(addr_fold), IP_VS_DH_TAB_BITS)
> is better.

I didn't notice this macro. I think this is a better option. Let me
amend the patch.
--=20
Don't stop with your first draft.
            - The Elements of Programming Style (Kernighan & Plauger)
