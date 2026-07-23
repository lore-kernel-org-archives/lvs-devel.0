Received: from mail-pj1-f45.google.com (mail-pj1-f45.google.com [209.85.216.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 292B947ACFF
	for <lvs-devel@vger.kernel.org>; Thu, 23 Jul 2026 18:45:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784832372; cv=none; b=kzSZoXHC6D/64cupG63CmoD5cdlDpJ+BWXFgFcv6Sp6Tr5ma6nEOSfthDvxchcG9/PqL+vVrl1i3rhR5qP9c/wx14RvpQLY6m4d42T7lgr8ad27G4H3qHZdKpkHpDzUyr92YjJLJ2WWIcd/TZ9r69jSvnx3n5ri3QIMkiAumiYY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784832372; c=relaxed/simple;
	bh=0DUXMETFOiPrjHj0I+f8Jjf1hUhgRxwBlToSkMOuX8E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=SfW5YW47KiVmHDu3Xd2Et1Vtooc28A9uca5H756kz5lUxIxZMoco98VBljVzukexRcFTuxpt+7Ru+4YOmumTM/ZYUNqfSjMspsOfgF83NsIjPHgzrWFBzZmDQTsrCIssUs571gB6xakcJQLRZ7jRMTVh4cjGdP/9LsSkbyoK3YA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=UcuaoKRQ; arc=none smtp.client-ip=209.85.216.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UcuaoKRQ"
Received: by mail-pj1-f45.google.com with SMTP id 98e67ed59e1d1-38e08baf860so1120998a91.2
        for <lvs-devel@vger.kernel.org>; Thu, 23 Jul 2026 11:45:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1784832355; x=1785437155; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=+cqQ6sQJkvsR3VtIbpEjUXStuHRs0SJj4jk7Uojzitk=;
        b=UcuaoKRQCbsReVhzJf/ZGJlXbh64b3U6AAC/KmroIrAb+XqaMu03L72UQmO1UfiKoH
         v5t8SdZGnnvGRm0kSFNoBBew4GakZFP6aUp0kui6MrYim7VuZY25y/41yO+xQdCUuVSt
         AYyG4u/HZr03V71uuN4Tg/H5roah86A3Hs7n7D/0j87fgcqbgrsjvKIgirqEL8EVhOiX
         7gOxTc3j6W0PsrZth3785bq/XUTCNFWLPQqtgqJpSDa8IKj5CH876rkjW/PMTVdQUJ0V
         ZoxYoGuEX+u+JYgBv4Zw44W3wGn4VBag2holCYN7hZ6yV5iHWiGOKFKN5GFOZqwlTJyB
         wTzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784832355; x=1785437155;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+cqQ6sQJkvsR3VtIbpEjUXStuHRs0SJj4jk7Uojzitk=;
        b=LWTijkjb7NIURrBfa2AUYvmoMi27w95ediQEQrdxgJIpw//er9CiHmnV6QmAFfMKZN
         ybpD0VDVvLzlUkCmMR4jbJivcIV8negAYsjGwsG2nrOneYsrNhDijfBisMjKH1oL6BNm
         ggfhUhaEqwgjujHSqh3Qd3PsoSt+OLDd6Z10c7Prk0zC1OSq1H9QuAX6v6B94g9s+I2s
         vLt/m5QLickvB3U6MQT3Q6RxhZCt5trcHXIXb5UjMqPlf3gdxbDL30cYK3GZe8RxxR5w
         k93zNY0AfOARhpY12PGjYMHZh/GK5uG9QNU48T3wfLgzxuo1w+MV1UqFdaRy0ra7wHbv
         9ZSQ==
X-Forwarded-Encrypted: i=1; AHgh+RrRXVyRKXDW4TMjNn7EZvxEm5pAwMqaTIgkjG0TFCR7ynH1oS9iw7zF/9Ja1lN726gVwMthvP/vVzM=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy1Dg7YI+ELr76f0Eanx5M0XBTcEPou4LgBr+Uvm9shCeggAu6w
	ZsDzNFHRIOgr+SYB228Mff9/Ke/5jjjEZc5etHGTEoR8zmcocmzlY4Bo
X-Gm-Gg: AR+sD12Od0IjdwqFe4QaQzbyd1/vcJUJ8t6XcHQ/On5RvaYwMyhsDkBT3b8fAWdLHdM
	LnXLjQShfk1Q6MX1vKQt4K/AYoaksXU+y946gLIW8Jjvdsb3IHLMC9yTa+erqIhSyUeWks9jKC3
	UvXDjRk+vY5A7DkRDJzw9942s44xseuV8fvvslpgLslBNSoW5pprXqCJbPPpcQ8uVJKP324UW0A
	++7Lmr19VMivgFxAxN6Ti5ZJu2rssZ5hYliaNVHlSd4ZnOlpeWOU/1fO7tdW9HZIFyaf1E8yoOI
	ZFJllvTXNrdnsOXg3mWoaXIpBnL9xsY1i3JFzmUDr2/kXuJT1u4+EwKbLXboyGtgrh+FfSbchqo
	Z5ODQ9rj1ox8t7ACVMZb0J1mF8LIYW+U59E1/HAtO5IFrczeKoCJLlRIdarS6749z4mPcVHmL
X-Received: by 2002:a17:90b:1350:b0:36d:66d4:270e with SMTP id 98e67ed59e1d1-38ec6455120mr4430242a91.5.1784832354540;
        Thu, 23 Jul 2026 11:45:54 -0700 (PDT)
Received: from ubuntu.. ([110.9.142.4])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-38f03af8a45sm308155a91.10.2026.07.23.11.45.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 23 Jul 2026 11:45:53 -0700 (PDT)
From: Sang-Heon Jeon <ekffu200098@gmail.com>
To: Julia.Lawall@inria.fr,
	Alex Deucher <alexander.deucher@amd.com>,
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
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Hans de Goede <hansg@kernel.org>,
	Hans Verkuil <hverkuil@kernel.org>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	=?UTF-8?q?Ilpo=20J=C3=A4rvinen?= <ilpo.jarvinen@linux.intel.com>,
	Jakub Kicinski <kuba@kernel.org>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Jaroslav Kysela <perex@perex.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jiri Pirko <jiri@resnulli.us>,
	"Joerg Roedel (AMD)" <joro@8bytes.org>,
	Johan Hovold <johan@kernel.org>,
	Jonathan Cameron <jic23@kernel.org>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Julian Anastasov <ja@ssi.bg>,
	Leon Romanovsky <leon@kernel.org>,
	Liam Girdwood <lgirdwood@gmail.com>,
	Linus Walleij <linusw@kernel.org>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Mark Brown <broonie@kernel.org>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Matthew Sakai <msakai@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Maxime Ripard <mripard@kernel.org>,
	Michael Turquette <mturquette@baylibre.com>,
	Mike Rapoport <rppt@kernel.org>,
	Miri Korenblit <miriam.rachel.korenblit@intel.com>,
	Nicolas Palix <nicolas.palix@imag.fr>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Ping-Ke Shih <pkshih@realtek.com>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Sebastian Reichel <sre@kernel.org>,
	Shuah Khan <shuah@kernel.org>,
	Simona Vetter <simona@ffwll.ch>,
	Simon Horman <horms@verge.net.au>,
	Stephen Boyd <sboyd@kernel.org>,
	Steve French <sfrench@samba.org>,
	Takashi Iwai <tiwai@suse.com>,
	Thomas Renninger <trenn@suse.com>,
	Thomas Zimmermann <tzimmermann@suse.de>,
	Tony Luck <tony.luck@intel.com>,
	Tvrtko Ursulin <tursulin@ursulin.net>,
	Vadim Fedorenko <vadim.fedorenko@linux.dev>,
	Vinod Koul <vkoul@kernel.org>,
	Will Deacon <will@kernel.org>,
	Yazen Ghannam <Yazen.Ghannam@amd.com>
Cc: cocci@inria.fr,
	amd-gfx@lists.freedesktop.org,
	dmaengine@vger.kernel.org,
	dm-devel@lists.linux.dev,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	intel-wired-lan@lists.osuosl.org,
	iommu@lists.linux.dev,
	linux-cifs@vger.kernel.org,
	linux-clk@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-edac@vger.kernel.org,
	linux-gpio@vger.kernel.org,
	linux-iio@vger.kernel.org,
	linux-input@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rtc@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-sound@vger.kernel.org,
	linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	nouveau@lists.freedesktop.org,
	platform-driver-x86@vger.kernel.org
Subject: [PATCH 00/36] treewide: remove conditional returns with no effect
Date: Fri, 24 Jul 2026 03:45:02 +0900
Message-ID: <20260723184538.3888637-1-ekffu200098@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hello,

While reading mm/memblock, I found a conditional return where both
branches return the same value:

	err = do_something();
	if (err)
		return err;
	return err;

Such code is usually a leftover from removing a statement between
the two returns, and the tree has about a hundred of these.

Patch 1 adds a Coccinelle script that matches the pattern, including
negation and constant-comparison variants. Where a local variable is
assigned right before the check, the assignment and the two returns
turn into a single return of the assigned expression.

Patches 2-36 are generated by the script, with hand fixes to restore
unexpectedly removed comments and to fix the formatting checkpatch.pl
complained about.

The patches are grouped by subsystem instead of split per file. If
you would rather split, merge or drop your part, just let me know
and I will address it in the next version.

All patches are independent and can be applied separately, but for
everyone's convenience, it would be nice if they were merged through
a single tree.

The series is based on next-20260721.

Sang-Heon Jeon (36):
  coccinelle: misc: add cond_return_no_effect.cocci
  drm/amd: remove conditional return with no effect
  drm/radeon: remove conditional return with no effect
  dpll: zl3073x: remove conditional return with no effect
  drm/i915: remove conditional return with no effect
  drm: remove conditional return with no effect
  net: ethernet: remove conditional return with no effect
  net: remove conditional return with no effect
  net: intel: remove conditional return with no effect
  wifi: remove conditional return with no effect
  ipvs: remove conditional return with no effect
  media: remove conditional return with no effect
  ALSA: remove conditional return with no effect
  ASoC: remove conditional return with no effect
  iio: remove conditional return with no effect
  Input: remove conditional return with no effect
  clk: remove conditional return with no effect
  crypto: drivers - remove conditional return with no effect
  dmaengine: qcom_hidma: remove conditional return with no effect
  stm class: remove conditional return with no effect
  RDMA/ocrdma: remove conditional return with no effect
  iommu/s390: remove conditional return with no effect
  dm vdo: remove conditional return with no effect
  pinctrl: mediatek: remove conditional return with no effect
  platform/x86: toshiba_haps: remove conditional return with no effect
  power: supply: pm8916_lbc: remove conditional return with no effect
  RAS/AMD/ATL: remove conditional return with no effect
  regulator: wm831x-isink: remove conditional return with no effect
  rtc: pcf2127: remove conditional return with no effect
  scsi: mpt3sas: remove conditional return with no effect
  thermal/drivers/k3_bandgap: remove conditional return with no effect
  USB: serial: ch341: remove conditional return with no effect
  usb: typec: fusb302: remove conditional return with no effect
  smb: client: remove conditional return with no effect
  cpupower: remove conditional return with no effect
  memblock: remove conditional return with no effect

 drivers/clk/clk-cs2000-cp.c                   |   6 +-
 drivers/clk/clk-lmk04832.c                    |  12 +-
 .../intel/qat/qat_common/adf_gen2_config.c    |   8 +-
 .../marvell/octeontx2/otx2_cpt_mbox_common.c  |   7 +-
 drivers/dma/qcom/hidma_ll.c                   |   6 +-
 drivers/dpll/zl3073x/dpll.c                   |   6 +-
 drivers/dpll/zl3073x/out.c                    |   8 +-
 drivers/gpu/drm/amd/amdgpu/gfx_v7_0.c         |   6 +-
 drivers/gpu/drm/amd/amdgpu/gfx_v9_0.c         |   6 +-
 drivers/gpu/drm/amd/amdgpu/gfx_v9_4_3.c       |   6 +-
 drivers/gpu/drm/amd/amdgpu/sdma_v4_4_2.c      |   6 +-
 drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c        |   6 +-
 drivers/gpu/drm/amd/amdgpu/sdma_v5_2.c        |   6 +-
 drivers/gpu/drm/amd/amdgpu/sdma_v6_0.c        |   6 +-
 drivers/gpu/drm/amd/amdgpu/uvd_v4_2.c         |   6 +-
 drivers/gpu/drm/amd/amdgpu/uvd_v5_0.c         |   6 +-
 drivers/gpu/drm/amd/amdgpu/uvd_v7_0.c         |   6 +-
 drivers/gpu/drm/amd/amdgpu/vce_v4_0.c         |   6 +-
 drivers/gpu/drm/amd/pm/legacy-dpm/kv_dpm.c    |  32 ++---
 drivers/gpu/drm/amd/pm/legacy-dpm/si_dpm.c    |   6 +-
 drivers/gpu/drm/amd/pm/swsmu/amdgpu_smu.c     |   6 +-
 .../gpu/drm/amd/pm/swsmu/smu11/arcturus_ppt.c |   6 +-
 .../gpu/drm/amd/pm/swsmu/smu11/navi10_ppt.c   |   6 +-
 .../gpu/drm/amd/pm/swsmu/smu11/smu_v11_0.c    |  19 +--
 .../gpu/drm/amd/pm/swsmu/smu11/vangogh_ppt.c  |   7 +-
 .../gpu/drm/amd/pm/swsmu/smu12/renoir_ppt.c   |   7 +-
 .../drm/amd/pm/swsmu/smu13/aldebaran_ppt.c    |   6 +-
 .../gpu/drm/amd/pm/swsmu/smu13/smu_v13_0.c    |  19 +--
 .../drm/amd/pm/swsmu/smu13/smu_v13_0_0_ppt.c  |   6 +-
 .../drm/amd/pm/swsmu/smu13/smu_v13_0_6_ppt.c  |  10 +-
 .../drm/amd/pm/swsmu/smu13/smu_v13_0_7_ppt.c  |   6 +-
 .../gpu/drm/amd/pm/swsmu/smu14/smu_v14_0.c    |  19 +--
 .../drm/amd/pm/swsmu/smu14/smu_v14_0_2_ppt.c  |   6 +-
 .../gpu/drm/amd/pm/swsmu/smu15/smu_v15_0.c    |   9 +-
 .../drm/amd/pm/swsmu/smu15/smu_v15_0_8_ppt.c  |  16 +--
 drivers/gpu/drm/i915/display/intel_hdmi.c     |   7 +-
 drivers/gpu/drm/i915/gvt/gtt.c                |   8 +-
 drivers/gpu/drm/imx/ipuv3/imx-drm-core.c      |   6 +-
 drivers/gpu/drm/nouveau/dispnv50/disp.c       |  14 +-
 .../drm/panel/panel-osd-osd101t2587-53ts.c    |   7 +-
 drivers/gpu/drm/radeon/ci_dpm.c               |   6 +-
 drivers/gpu/drm/radeon/kv_dpm.c               |  30 ++---
 drivers/gpu/drm/radeon/si_dpm.c               |  14 +-
 drivers/gpu/drm/tilcdc/tilcdc_drv.c           |   6 +-
 drivers/hwtracing/stm/core.c                  |   8 +-
 drivers/iio/light/isl29028.c                  |   6 +-
 drivers/iio/light/tsl2583.c                   |  14 +-
 drivers/iio/magnetometer/ak8974.c             |   6 +-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c   |   7 +-
 drivers/input/keyboard/pmic8xxx-keypad.c      |   8 +-
 drivers/input/mouse/synaptics_i2c.c           |   6 +-
 drivers/input/rmi4/rmi_smbus.c                |   7 +-
 drivers/iommu/s390-iommu.c                    |   8 +-
 drivers/md/dm-vdo/encodings.c                 |   8 +-
 drivers/media/i2c/mt9p031.c                   |   6 +-
 .../microchip/microchip-sama7g5-isc.c         |   7 +-
 .../media/platform/qcom/iris/iris_resources.c |   6 +-
 .../media/platform/qcom/venus/pm_helpers.c    |   7 +-
 drivers/media/platform/renesas/rcar-csi2.c    |   6 +-
 .../platform/samsung/s3c-camif/camif-core.c   |   7 +-
 drivers/media/usb/dvb-usb-v2/mxl111sf.c       |  12 +-
 drivers/media/usb/gspca/jl2005bcd.c           |   7 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c  |   6 +-
 .../ethernet/aquantia/atlantic/aq_macsec.c    |   6 +-
 .../ethernet/freescale/dpaa2/dpaa2-switch.c   |   6 +-
 drivers/net/ethernet/freescale/gianfar.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c   |   8 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c   |   6 +-
 drivers/net/ethernet/intel/igc/igc_phy.c      |   6 +-
 .../ethernet/qlogic/netxen/netxen_nic_hw.c    |   7 +-
 .../ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |   6 +-
 drivers/net/ethernet/renesas/rtsn.c           |   7 +-
 drivers/net/phy/microchip_t1.c                |   6 +-
 drivers/net/pse-pd/tps23881.c                 |   6 +-
 drivers/net/wireless/ath/ath6kl/init.c        |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/link.c |   6 +-
 .../wireless/realtek/rtlwifi/rtl8821ae/hw.c   |   7 +-
 drivers/net/wireless/realtek/rtw89/mac.c      |   6 +-
 drivers/net/wireless/realtek/rtw89/mac_be.c   |   6 +-
 .../pinctrl/mediatek/pinctrl-mtk-common-v2.c  |   6 +-
 drivers/platform/x86/toshiba_haps.c           |   6 +-
 drivers/power/supply/pm8916_lbc.c             |   8 +-
 drivers/ras/amd/atl/map.c                     |   6 +-
 drivers/regulator/wm831x-isink.c              |   6 +-
 drivers/rtc/rtc-pcf2127.c                     |   7 +-
 drivers/scsi/mpt3sas/mpt3sas_base.c           |   6 +-
 drivers/thermal/k3_bandgap.c                  |   7 +-
 drivers/usb/serial/ch341.c                    |   8 +-
 drivers/usb/typec/tcpm/fusb302.c              |  14 +-
 fs/smb/client/smb1maperror.c                  |   6 +-
 mm/memblock.c                                 |   7 +-
 net/netfilter/ipvs/ip_vs_sync.c               |   7 +-
 .../misc/cond_return_no_effect.cocci          | 121 ++++++++++++++++++
 sound/pci/echoaudio/echoaudio_dsp.c           |   6 +-
 sound/pci/echoaudio/layla24_dsp.c             |   6 +-
 sound/pci/riptide/riptide.c                   |   5 +-
 sound/soc/amd/acp/acp-mach-common.c           |  11 +-
 sound/soc/intel/atom/sst-mfld-platform-pcm.c  |   7 +-
 sound/soc/samsung/smdk_spdif.c                |   8 +-
 sound/soc/sof/intel/hda-dsp.c                 |   6 +-
 sound/usb/mixer_scarlett.c                    |  26 ++--
 tools/power/cpupower/utils/powercap-info.c    |   2 -
 102 files changed, 295 insertions(+), 643 deletions(-)
 create mode 100644 scripts/coccinelle/misc/cond_return_no_effect.cocci

--
2.43.0

