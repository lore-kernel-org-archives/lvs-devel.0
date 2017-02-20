From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net-next 0/4] update ipvs sysctl document
Date: Mon, 20 Feb 2017 16:31:34 +0800
Message-ID: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=4eY1TDrPNwjPOs6QPJExsPlqUOi00Sl6ayCZBY9Q2fY=;
        b=TAecdqu7tDf9Wl/EyuRdxK62/UkR9pc47bn+r6bVSd6vHA/4r0UDCPJJsjVl1ESoPu
         3CWbO/OWn+iQ7c53OktR0x+s7iAvh80MhojuZYrb8Wwx4nsJ+Q8v5G4JtWFSUCn0PcZs
         Ty2ClMrwYlgAIAZr2Btk4FU/bDk5mcltsjeBSWEHdHsvq9ntIdKtOria1wPwsA12YG9q
         eyBy3f27/ZTt4D6POusakzRN4qnHXUA/ZrTezoZRpHE8Wo0L1f0LK4MQMdZwsOtGhzB8
         6/i3XH2QzmLuf0PjjGhFBtjzCYDDn4ZJR/TV/JHxULL/uOQj5izaTImltAckoMD0aBka
         yEww==
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>

Fix and add some new ipvs sysctl options. Also use tab instead of
whitespaces to indent the descriptions.

V2: Fix some descriptions based on Julian's advice.

Hangbin Liu (4):
  ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
  ipvs: Document sysctl sync_qlen_max and sync_sock_size
  ipvs: Document sysctl sync_ports
  ipvs: Document sysctl pmtu_disc

 Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
 1 file changed, 60 insertions(+), 8 deletions(-)

-- 
2.5.5

