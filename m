From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 0/4] update ipvs sysctl document
Date: Fri, 17 Feb 2017 14:33:57 +0800
Message-ID: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=b0JL8RbMX/UT79aQjgUn6u+s0XpYN1RYsXaFphiK36I=;
        b=clu2abiImREmtPdC1vq2oXrDOFf1AmVTpKTt38ccFfzy6iynZLVYhJNpC0sndeK/Ma
         pjQWBMGsAzDb557Iqtf27e4ntHqgaWMhO8B8D2H2a2ZhorbrGsnMBe+njvWJlXQFb1MZ
         lCLBA2qc26dHUCWBoG1cTrOYbX6VfQIzVP4ukGM64fK0H8UMk6mkmMFHZtMigaG2kPDc
         U4GsxO46FroLhNaZ9AD45Y+0g+g0IfyHke3AOuwdDQjmDE2d2u1GAaljyYRhLvcwfaJI
         S1j1EQzw55tEqo1+rWoJRszLopi9eV3S0UpR21gXjlqVCaB1sSzJY+APUUyAxCIHDFWm
         9m4w==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Hangbin Liu <liuhangbin@gmail.com>

Fix and add some new ipvs sysctl options. Also use tab instead of whitespaces
to indent the descriptions.

Hangbin Liu (4):
  ipvs: fix sync_threshold description and add sync_refresh_period,
    sync_retries
  ipvs: Document sysctl sync_qlen_max and sync_sock_size
  ipvs: Document sysctl sync_ports
  ipvs: Document sysctl pmtu_disc

 Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
 1 file changed, 60 insertions(+), 8 deletions(-)

-- 
2.5.5

