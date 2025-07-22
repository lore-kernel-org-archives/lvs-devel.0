Received: from smtpbgau2.qq.com (smtpbgau2.qq.com [54.206.34.216])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CE7A28B7F1;
	Tue, 22 Jul 2025 08:06:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=54.206.34.216
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753171582; cv=none; b=OYZ8kjmYqkrJs46k0EzoVI5LBQKItMXWK24tFQjhclwuPTzlhB0w5Ivzi629uHPXEZCX31AVJgibe4HAtdbVXOWAHeY4uWITunYxxLk110Yl6HMVL9QyvkZ7wU27Zyok+cRefRiOtzAOcvitPofe5LD7XYNTYt72lLRsHQraFL0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753171582; c=relaxed/simple;
	bh=Jk2XBgvKJ+egnwck4cqJCxB9P39vR2BJ63hOYEVBH0M=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=tlZfVLB1zNOgU2uW6ZdEbohM/qfx4Lh5DJ1K9ANEJM2EAbBK05uTfUxeBRUDx7KB4BHiASgKTZlcWki898EORjdfeB5HthMH8THuXVKs9eSq5zw9aAX+sZUfqR5YDFPgE1U/b3d/WonNLPT5MZ16n8ykuHUPb2PwEEkk++upcsQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com; spf=pass smtp.mailfrom=uniontech.com; dkim=pass (1024-bit key) header.d=uniontech.com header.i=@uniontech.com header.b=JLUZkLPo; arc=none smtp.client-ip=54.206.34.216
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uniontech.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=uniontech.com header.i=@uniontech.com header.b="JLUZkLPo"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uniontech.com;
	s=onoh2408; t=1753171575;
	bh=Jk2XBgvKJ+egnwck4cqJCxB9P39vR2BJ63hOYEVBH0M=;
	h=Message-ID:Date:MIME-Version:Subject:To:From;
	b=JLUZkLPogojFab+JQCr3BrRFI77kwCudHZiILKyOJGbsgG5QIKNjVZBzbUvqQ+miD
	 riB28z4V4Ig51RBaSiGDmYDyTO2TQgz0PXiJjQ0qt1qt54FXw//tpvjVeGXJMmXb+2
	 3mrySzazFccpKzPLxGlOMB3a8srIngR4R3HljyWM=
X-QQ-mid: zesmtpip3t1753171528t3ec7333b
X-QQ-Originating-IP: /pRypQO32Iz44++x6tk4NLGOP28Tf/v1ADE1NLN9Nek=
Received: from [IPV6:240e:668:120a::212:232] ( [localhost])
	by bizesmtp.qq.com (ESMTP) with 
	id ; Tue, 22 Jul 2025 16:05:26 +0800 (CST)
X-QQ-SSF: 0000000000000000000000000000000
X-QQ-GoodBg: 1
X-BIZMAIL-ID: 4268784135301633643
EX-QQ-RecipientCnt: 17
Message-ID: <4DFD87AA0CE5EA72+aebc5df6-9174-4ecf-9dc9-3abb312defc1@uniontech.com>
Date: Tue, 22 Jul 2025 16:05:26 +0800
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RESEND] ipvs: ip_vs_conn_expire_now: Rename del_timer in
 comment
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org, davem@davemloft.net,
 edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
 netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org, zhanjun@uniontech.com,
 niecheng1@uniontech.com, guanwentao@uniontech.com, wangyuli@deepin.org
References: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>
 <aH8Ek6XA_EFr_XWh@calendula>
Content-Language: en-US
From: WangYuli <wangyuli@uniontech.com>
Autocrypt: addr=wangyuli@uniontech.com; keydata=
 xjMEZoEsiBYJKwYBBAHaRw8BAQdAyDPzcbPnchbIhweThfNK1tg1imM+5kgDBJSKP+nX39DN
 IVdhbmdZdWxpIDx3YW5neXVsaUB1bmlvbnRlY2guY29tPsKJBBMWCAAxFiEEa1GMzYeuKPkg
 qDuvxdofMEb0C+4FAmaBLIgCGwMECwkIBwUVCAkKCwUWAgMBAAAKCRDF2h8wRvQL7g0UAQCH
 3mrGM0HzOaARhBeA/Q3AIVfhS010a0MZmPTRGVfPbwD/SrncJwwPAL4GiLPEC4XssV6FPUAY
 0rA68eNNI9cJLArOOARmgSyJEgorBgEEAZdVAQUBAQdA88W4CTLDD9fKwW9PB5yurCNdWNS7
 VTL0dvPDofBTjFYDAQgHwngEGBYIACAWIQRrUYzNh64o+SCoO6/F2h8wRvQL7gUCZoEsiQIb
 DAAKCRDF2h8wRvQL7sKvAP4mBvm7Zn1OUjFViwkma8IGRGosXAvMUFyOHVcl1RTgFQEAuJkU
 o9ERi7qS/hbUdUgtitI89efbY0TVetgDsyeQiwU=
In-Reply-To: <aH8Ek6XA_EFr_XWh@calendula>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------miZQFZGDnPdt0uLvzGTFutMR"
X-QQ-SENDSIZE: 520
Feedback-ID: zesmtpip:uniontech.com:qybglogicsvrgz:qybglogicsvrgz8a-1
X-QQ-XMAILINFO: NHAdjHOky+HcUZRg3WmYNwzcU2POO4FJYfH2wdaWRfmco+QK+g968rXU
	pxEmoztRQC1bbWst3GFhTen7MTyOIVh8A/74JuXFqpGcOydyPoM9D47o/6wKvJbREYiUtq1
	Nyyvt35CaISz8XAmLUbBwMu5UtHaPiBJQ4u/gEjr4Ve0R0qlCXgUR22f8txN1lDm0E/xra8
	z+U5TUa+ErpRRlmK7jX4p/vkIyO+nK4fpjkiI2PtsYFnoe0GeueZuAjp1/3COMn0uho8fju
	XSttYfG+zmH+qtciSi80hxnKIyyQ2HXMvofxVgCitNpI2g9S+HJ6VZE8Fyt6ANno31ipjpo
	8BAkLEtBv/a7GLkr7PoQCKzbdBJyDrG9OjkUdG8B48jxCPIu4T/hzubmvh9eqDiKOjOG3Gd
	frNRXK22A6iVQIx7Qx8FrLWVX1ErP07q2XxUpFVwu+GNPZ0CAd65HssEYf3KNCWXl2bEJuu
	90fcNCsQhWRdPziPmeCK8RXLbJvrUPmneZnPw+j3lG+w4b+X2UP6lYC6B0TlWKCogZ1xvdG
	3Y/kk+15RhKogpBbewKVL280LT2zqBgYHSHY/spjtS+LFa9Fe81QZgwDcCT6hBYC9qRUdNh
	sxVdlGhJQayiOQoq5F1FpNBbq8Fxn+JJxGqBJ4UysSKkFsH9AbXW73kZboqvJpeyzQJQ2Ls
	xdp3oMekR13zIVSl0k5YSh1vaDRuxBlCPpt+m2X6nSKtrHS321pH5Vif3ThgqPMC/bH/n1e
	R7DW/M/fTcEqjMuZbCnmBL3P0RalwjZ9wxyYxe2Hm8wuqDJgL4iRN36tnmuiPsfzC15Pb9s
	JM9D8ItuqkE6diBwltcUu06Mh6fSzkebp26cqirseaoO1k0KcWBbl7pYHMhkh2unw1esyA3
	9qLyr9NHu9jmjjeXs9Mz10MHTAiJyl/ciGIRyEo6YheWummIxR3HxcWzN4LFtgkyTOcG9zy
	SoMdj9TJPLjpJi+10OLa4Yx0NyJfHqRnItlME3Js5fDnfv1EZZXsgNuAkiD1RQyQIMJiMfZ
	1sCfYRfxcLDtIUmWeZiKt/+l8+p1n9WB9sazW3u1BgRpKbkNa9Yqd6zrZMmsw+H8wi0V7UV
	mPSLjjcGBLn9C+TsyIz8mrrKF/KX4lXrZcpPXlj8ICTHhRkYtMjAKuP31uqyQ05Vg==
X-QQ-XMRINFO: NyFYKkN4Ny6FSmKK/uo/jdU=
X-QQ-RECHKSPAM: 0

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------miZQFZGDnPdt0uLvzGTFutMR
Content-Type: multipart/mixed; boundary="------------wln8Z5WJ90acIPVp5CBvJ1Z0";
 protected-headers="v1"
From: WangYuli <wangyuli@uniontech.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org, davem@davemloft.net,
 edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
 netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org, zhanjun@uniontech.com,
 niecheng1@uniontech.com, guanwentao@uniontech.com, wangyuli@deepin.org
Message-ID: <aebc5df6-9174-4ecf-9dc9-3abb312defc1@uniontech.com>
Subject: Re: [PATCH RESEND] ipvs: ip_vs_conn_expire_now: Rename del_timer in
 comment
References: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>
 <aH8Ek6XA_EFr_XWh@calendula>
In-Reply-To: <aH8Ek6XA_EFr_XWh@calendula>

--------------wln8Z5WJ90acIPVp5CBvJ1Z0
Content-Type: multipart/mixed; boundary="------------07PXpVmU8b1YT04K6viN7jix"

--------------07PXpVmU8b1YT04K6viN7jix
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkgUGFibG8gTmVpcmEgQXl1c28sDQoNCk9uIDIwMjUvNy8yMiAxMToyNSwgUGFibG8gTmVp
cmEgQXl1c28gd3JvdGU6DQo+IE9uIEZyaSwgSnVsIDA0LCAyMDI1IGF0IDA0OjM1OjUzUE0g
KzA4MDAsIFdhbmdZdWxpIHdyb3RlOg0KPj4gQ29tbWl0IDhmYTcyOTJmZWU1YyAoInRyZWV3
aWRlOiBTd2l0Y2gvcmVuYW1lIHRvIHRpbWVyX2RlbGV0ZVtfc3luY10oKSIpDQo+PiBzd2l0
Y2hlZCBkZWxfdGltZXIgdG8gdGltZXJfZGVsZXRlLCBidXQgZGlkIG5vdCBtb2RpZnkgdGhl
IGNvbW1lbnQgZm9yDQo+PiBpcF92c19jb25uX2V4cGlyZV9ub3coKS4gTm93IGZpeCBpdC4N
Cj4gJCBnaXQgZ3JlcCBkZWxfdGltZXIgbmV0L25ldGZpbHRlci8NCj4gbmV0L25ldGZpbHRl
ci9pcHZzL2lwX3ZzX2xibGMuYzogKiAgICAgSnVsaWFuIEFuYXN0YXNvdiAgICAgICAgOiAg
ICByZXBsYWNlZCBkZWxfdGltZXIgY2FsbCB3aXRoIGRlbF90aW1lcl9zeW5jDQo+IG5ldC9u
ZXRmaWx0ZXIvaXB2cy9pcF92c19sYmxjLmM6ICogICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIGhhbmRsZXIgYW5kIGRlbF90aW1lciB0aHJlYWQgaW4gU01QDQo+DQo+IFdp
ZGVyIHNlYXJjaCwgaW4gdGhlIG5ldCB0cmVlOg0KPg0KPiBuZXQvaXB2NC9pZ21wLmM6ICog
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHdoaWNoIGNhdXNlZCBhICJk
ZWxfdGltZXIoKSBjYWxsZWQNCj4gbmV0L2lwdjQvaWdtcC5jOiAqICAgICAgICAgICAgICBD
aHJpc3RpYW4gRGF1ZHQgOiAgICAgICByZW1vdmVkIGRlbF90aW1lciBmcm9tDQo+DQo+IE1h
eWJlIHRoZXNlIGFyZSBvbmx5IGZvciBoaXN0b3JpY2FsIHB1cnBvc2UsIHNvIGxlYXZpbmcg
dGhlbSB1bnRvdWNoZWQNCj4gaXMgZmluZS4NCj4NCkkgaW50ZW50aW9uYWxseSBtb2RpZmll
ZCBvbmx5IHRoaXMgcGFydCwgbGVhdmluZyB0aGUgb3RoZXIgcGxhY2VzIHlvdSANCmZvdW5k
IHVudG91Y2hlZC4NCg0KTXkgZ29hbCB3YXMgdG8gdXBkYXRlIG9ubHkgdGhlIGNvbW1lbnQg
Zm9yIHRoaXMgY29kZSBibG9jaywgbm90IHRoZSANCmZpbGUncyBjaGFuZ2Vsb2cuDQoNCg0K
VGhhbmtzLA0KDQotLSANCldhbmdZdWxpDQo=
--------------07PXpVmU8b1YT04K6viN7jix
Content-Type: application/pgp-keys; name="OpenPGP_0xC5DA1F3046F40BEE.asc"
Content-Disposition: attachment; filename="OpenPGP_0xC5DA1F3046F40BEE.asc"
Content-Description: OpenPGP public key
Content-Transfer-Encoding: quoted-printable

-----BEGIN PGP PUBLIC KEY BLOCK-----

xjMEZoEsiBYJKwYBBAHaRw8BAQdAyDPzcbPnchbIhweThfNK1tg1imM+5kgDBJSK
P+nX39DNIVdhbmdZdWxpIDx3YW5neXVsaUB1bmlvbnRlY2guY29tPsKJBBMWCAAx
FiEEa1GMzYeuKPkgqDuvxdofMEb0C+4FAmaBLIgCGwMECwkIBwUVCAkKCwUWAgMB
AAAKCRDF2h8wRvQL7g0UAQCH3mrGM0HzOaARhBeA/Q3AIVfhS010a0MZmPTRGVfP
bwD/SrncJwwPAL4GiLPEC4XssV6FPUAY0rA68eNNI9cJLArOOARmgSyJEgorBgEE
AZdVAQUBAQdA88W4CTLDD9fKwW9PB5yurCNdWNS7VTL0dvPDofBTjFYDAQgHwngE
GBYIACAWIQRrUYzNh64o+SCoO6/F2h8wRvQL7gUCZoEsiQIbDAAKCRDF2h8wRvQL
7sKvAP4mBvm7Zn1OUjFViwkma8IGRGosXAvMUFyOHVcl1RTgFQEAuJkUo9ERi7qS
/hbUdUgtitI89efbY0TVetgDsyeQiwU=3D
=3DBlkq
-----END PGP PUBLIC KEY BLOCK-----

--------------07PXpVmU8b1YT04K6viN7jix--

--------------wln8Z5WJ90acIPVp5CBvJ1Z0--

--------------miZQFZGDnPdt0uLvzGTFutMR
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature.asc"

-----BEGIN PGP SIGNATURE-----

wnsEABYIACMWIQRrUYzNh64o+SCoO6/F2h8wRvQL7gUCaH9GRgUDAAAAAAAKCRDF2h8wRvQL7gwh
AQD+b6zSXab3OX8ehDxFFWIDaNEuEcWNgwe8KckxeUJLCwEA/a+pT5OaBoXOrDvuUSxrem7LXlM6
dIjddT3Qgh/H1gg=
=xVG0
-----END PGP SIGNATURE-----

--------------miZQFZGDnPdt0uLvzGTFutMR--
