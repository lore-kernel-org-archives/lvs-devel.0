Received: from mx0b-00069f02.pphosted.com (mx0b-00069f02.pphosted.com [205.220.177.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC3294C77D1;
	Thu,  6 Aug 2026 19:07:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.177.32
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786043241; cv=none; b=XA7yYFuFFFAEYu+M0Hx8Op5xzSjBE853LviW5VeC6mOdihp8C5/MkwcD4iGoZJDTYzhg1X08+eibzaJrd2b1lxxvYLrKpn8SNzHBsszDAXZE88ougZ8Uiw5GlrjAMDegtnknNtNSlAOQq/+Ht0AyCNKjYseQiijCorVYbUvVkdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786043241; c=relaxed/simple;
	bh=WXcm2Yb5I04oLe14dcXdrEPwOR8hGoCD+QeGAqYfYQw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=AEHc1hF25SowMbEOHH1pCtzo+9NhhXR8eZdjexjXEJITmo4nkfXlmFAGt1iIzc8D9d8ucOiSMcc8J+ZsgNaH6p36PVOAfJwd1Bn33oFKpmet3FB1qRxL7dTgXvVPFzmpP7Ah/od8cky199kShTwnh3+V41NlwUo//i2daPkIZe0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=nA1aUYEN; arc=none smtp.client-ip=205.220.177.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nA1aUYEN"
Received: from pps.filterd (m0333520.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 676Ftr4v4168306;
	Thu, 6 Aug 2026 19:06:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=85JNUC8SyfLYyGobZYpdZmxyQGF0qjVqbjDUd/Wkets=; b=
	nA1aUYENomsR9p7hfDkQr6KalTZrWQW8NET0IkudX6kxW006ofYrtz87Qku7QfJU
	1lbtfpVmJ42Q3AQE1tcbOw0dHj5dJSylYxq+m2+YcyLW9melEp/Zo40HFGHB54iG
	OcTwtR+niQLcarL+4OWP5kUShgYJOMrLwxEqqSkY7Lj2zjgD/sgtw+C5rg7PDGAH
	Gv3g1ppfRFvZh8DYeUX2gV+upEZO5qZ40tc03kMw1uUKshv2LOqjagJ3HbvFdCxa
	5hBpF9vOLZ/60dXew31tSvX4uLcqli6uolj+khGTMmHGGzK/4pK/rJL+YY5xBUHb
	pPRuZrwRVaPtUZ7W/V2+uA==
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.appoci.oracle.com [147.154.18.20])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4fs8ugpqtf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 06 Aug 2026 19:06:26 +0000 (GMT)
Received: from pps.filterd (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 676J0b6k024663;
	Thu, 6 Aug 2026 19:06:25 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTPS id 4fs78w56e3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 06 Aug 2026 19:06:25 +0000 (GMT)
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
	by pps.reinject (8.18.1.12/8.18.1.12) with ESMTP id 676J6LgY011247;
	Thu, 6 Aug 2026 19:06:24 GMT
Received: from ca-mkp2.ca.oracle.com.com (mpeterse-ol9.allregionaliads.osdevelopmeniad.oraclevcn.com [100.100.251.135])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTP id 4fs78w56b9-3;
	Thu, 06 Aug 2026 19:06:24 +0000 (GMT)
From: "Martin K. Petersen" <martin.petersen@oracle.com>
To: Julia.Lawall@inria.fr, Alex Deucher <alexander.deucher@amd.com>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Alexandre Belloni <alexandre.belloni@bootlin.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Andrew Morton <akpm@linux-foundation.org>,
        Arkadiusz Kubalewski <arkadiusz.kubalewski@intel.com>,
        Borislav Petkov <bp@alien8.de>,
        =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
        Daniel Lezcano <daniel.lezcano@kernel.org>,
        David Airlie <airlied@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Hans de Goede <hansg@kernel.org>, Hans Verkuil <hverkuil@kernel.org>,
        Heikki Krogerus <heikki.krogerus@linux.intel.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        =?UTF-8?q?Ilpo=20J=C3=A4rvinen?= <ilpo.jarvinen@linux.intel.com>,
        Jakub Kicinski <kuba@kernel.org>,
        "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Jaroslav Kysela <perex@perex.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
        Jiri Pirko <jiri@resnulli.us>, "Joerg Roedel (AMD)" <joro@8bytes.org>,
        Johan Hovold <johan@kernel.org>, Jonathan Cameron <jic23@kernel.org>,
        Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
        Julian Anastasov <ja@ssi.bg>, Leon Romanovsky <leon@kernel.org>,
        Liam Girdwood <lgirdwood@gmail.com>, Linus Walleij <linusw@kernel.org>,
        Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
        Mark Brown <broonie@kernel.org>, Matthew Sakai <msakai@redhat.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Maxime Ripard <mripard@kernel.org>,
        Michael Turquette <mturquette@baylibre.com>,
        Mike Rapoport <rppt@kernel.org>,
        Miri Korenblit <miriam.rachel.korenblit@intel.com>,
        Nicolas Palix <nicolas.palix@imag.fr>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Paolo Abeni <pabeni@redhat.com>, Ping-Ke Shih <pkshih@realtek.com>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Rodrigo Vivi <rodrigo.vivi@intel.com>,
        Sebastian Reichel <sre@kernel.org>, Shuah Khan <shuah@kernel.org>,
        Simona Vetter <simona@ffwll.ch>, Simon Horman <horms@verge.net.au>,
        Stephen Boyd <sboyd@kernel.org>, Steve French <sfrench@samba.org>,
        Takashi Iwai <tiwai@suse.com>, Thomas Renninger <trenn@suse.com>,
        Thomas Zimmermann <tzimmermann@suse.de>,
        Tony Luck <tony.luck@intel.com>, Tvrtko Ursulin <tursulin@ursulin.net>,
        Vadim Fedorenko <vadim.fedorenko@linux.dev>,
        Vinod Koul <vkoul@kernel.org>, Will Deacon <will@kernel.org>,
        Yazen Ghannam <Yazen.Ghannam@amd.com>,
        Sang-Heon Jeon <ekffu200098@gmail.com>
Cc: "Martin K . Petersen" <martin.petersen@oracle.com>, cocci@inria.fr,
        amd-gfx@lists.freedesktop.org, dmaengine@vger.kernel.org,
        dm-devel@lists.linux.dev, dri-devel@lists.freedesktop.org,
        intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org,
        iommu@lists.linux.dev, linux-cifs@vger.kernel.org,
        linux-clk@vger.kernel.org, linux-crypto@vger.kernel.org,
        linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-input@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-mm@kvack.org, linux-pm@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-rtc@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-sound@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        nouveau@lists.freedesktop.org, platform-driver-x86@vger.kernel.org
Subject: Re: (subset) [PATCH 00/36] treewide: remove conditional returns with no effect
Date: Thu,  6 Aug 2026 15:06:08 -0400
Message-ID: <178589207129.336697.9870225893827541543.b4-ty@oracle.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260723184538.3888637-1-ekffu200098@gmail.com>
References: <20260723184538.3888637-1-ekffu200098@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-06_02,2026-08-06_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 adultscore=0
 spamscore=0 malwarescore=0 bulkscore=0 lowpriorityscore=0 mlxscore=0
 phishscore=0 mlxlogscore=672 suspectscore=0 classifier=spam adjust=0
 reason=mlx scancount=1 engine=8.19.0-2606160000 definitions=main-2608060149
X-Proofpoint-ORIG-GUID: XGMDaQGIFMb57T6Q2yvPQTQQt2debxfq
X-Authority-Analysis: v=2.4 cv=XqnK/1F9 c=1 sm=1 tr=0 ts=6a74db32 b=1 cx=c_pps
 a=e1sVV491RgrpLwSTMOnk8w==:117 a=e1sVV491RgrpLwSTMOnk8w==:17
 a=IkcTkHD0fZMA:10 a=Sv0fKeRqtYgA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=BqU2WV_vvsyTyxaotp0D:22 a=VwQbUJbxAAAA:8
 a=Br-j9HdbvUlrMjNZj6IA:9 a=QEXdDO2ut3YA:10 a=5yU3S35YU4bGjq-dph-N:22
 a=Bho9c0fBagfJEIQBS7DQ:22 cc=ntf awl=host:13510
X-Proofpoint-Spam-Info: AW1haW4tMjYwODA2MDE0OSBTYWx0ZWRfX6uIK9jT+2Jev
 rYS5Xc6Wjv9hMYRtyD0NY9wioUhY1o9ts8S44XrOIykROIC2fMM+q3H5rjkub44bNgkLDQ3tnSe
 fkx9LiuU0Ioed9eVzRB8PP2qYuZIVaHGDH9Vr333gSb2ZgsHD92v
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODA2MDE0OSBTYWx0ZWRfX43FUiflrVixJ
 FNgAKsr+fsfl0ktZltC3fvW6MVFcRQRy/oySHj8nQQDMOHwfS94QLWHrXArK3j62D1c6aNzQrnl
 2DtOuGbPQocnjuSCI1ny1WWYx/7jkkjlcfyl+lp7TEesEfkx307+KuCZo0OgIxbIwfa72MWD4em
 tn6/hMd/QXx6zH3wP5OlhrMzlp2qKgIxJlelAMfUWIkruyj4hnvKzGUkqPoF4QRZ71As9I8pV2j
 DMm/cMIaHufC6lXcsuKfUk0yiqWTx1Zr8LtQAR498eW34hEj3pAMHucta0+1CKmEnv9EN7lkU/M
 FG7jgW8yHOjl2TgueMJFzovO4heKYSqjW47oC3CHVujyZPMUqifsWdUKFoxdhd+EKhXdCEJL9b0
 LGCES5HP/CdGIqj2UaaWymZGJVFVJ4RBD/aEk7/710HO5x59Z+gVx3LZGgty2YUYCbgJE7oGTWH
 QPXliDM2eYx5QgvaSSBlrfWn/1V9lBD33lbCDCaI=
X-Proofpoint-GUID: XGMDaQGIFMb57T6Q2yvPQTQQt2debxfq

On Fri, 24 Jul 2026 03:45:02 +0900, Sang-Heon Jeon wrote:

> While reading mm/memblock, I found a conditional return where both
> branches return the same value:
> 
> 	err = do_something();
> 	if (err)
> 		return err;
> 	return err;
> 
> [...]

Applied to 7.3/scsi-queue, thanks!

[30/36] scsi: mpt3sas: remove conditional return with no effect
        https://git.kernel.org/mkp/scsi/c/c79f9bf2d87f

-- 
Martin K. Petersen
