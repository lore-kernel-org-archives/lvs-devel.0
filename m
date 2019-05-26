From: Jacky Hu <hengqing.hu@gmail.com>
Subject: [PATCH v7 0/2] Allow tunneling with gue encapsulation
Date: Sun, 26 May 2019 23:01:04 +0800
Message-ID: <20190526150106.18622-1-hengqing.hu@gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=from:to:cc:subject:date:message-id:mime-version
	:content-transfer-encoding;
	bh=MJH8yOdBYSQpJIiPGRwtg0joAHpICqlf8Kg5oBlh5Kc=;
	b=jBzguhtPPETQGpgwUEAKHQnAvkXpOegttwv7BLoqIl30Edr3MiRrC7DmB0Ru2onzCm
	QW27jwjf4pT/EjdC2Ig6tmhm0Xjri+mpGQguOXaRNOVWrx3dItbX+ROHgiK1JyRABT8z
	jNxrBj7eAWuabkdZe3j/Tp+M6Pto6w0tFGvEkPGnu25Vm6YO3wXCHa7wofoNbmpu1WIM
	Pbk3019eciu8V2IpADFkwPaI6thfwBRqsn1HAO7ocuCbLyVefOoiEgTb+dyp5zB353ah
	y3JaMkKVJjzuytKoPsYli2Y0Wz12nR/cvA5ynmePTle0XMHp1Fow+s1IblhQ4Nrtb8Zt
	HR6A==
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: hengqing.hu@gmail.com
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, horms@verge.net.au, jacky.hu@walmart.com, brouer@redhat.com, jason.niesz@walmart.com

This patchset allows tunneling with gue encapsulation.

v7->v6:
  1) fix type of local variable in parse_tun_type
  2) use up to 4 letters in the comments
  3) document new options

v6->v5:
  1) split the patch into two:
     - ipvsadm: convert options to unsigned long long
     - ipvsadm: allow tunneling with gue encapsulation
  2) do not mix static and dynamic allocation in fwd_tun_info
  3) use correct nla_get/put function for tun_flags
  4) fixed || style
  5) use correct return value for parse_tun_type

v5->v4:
  1) add checksum support for gue encapsulation

v4->v3:
  1) removed changes to setsockopt interface
  2) use correct nla_get/put function for tun_port

v3->v2:
  1) added missing break statements to a few switch cases

v2->v1:
  1) pass tun_type and tun_port as new optional parameters
     instead of a few bits in existing conn_flags parameters

Jacky Hu (2):
  ipvsadm: convert options to unsigned long long
  ipvsadm: allow tunneling with gue encapsulation

 ipvsadm.8         |  72 ++++++++
 ipvsadm.c         | 427 +++++++++++++++++++++++++++++++++++++++-------
 libipvs/ip_vs.h   |  28 +++
 libipvs/libipvs.c |  15 ++
 4 files changed, 476 insertions(+), 66 deletions(-)

-- 
2.21.0

