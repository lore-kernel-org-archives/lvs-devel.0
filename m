From: yunhong-cgl jiang <xintian1976@gmail.com>
Subject: Long delay on estimation_timer causes packet latency
Date: Thu, 16 Apr 2020 15:00:53 -0700
Message-ID: <D25792C1-1B89-45DE-9F10-EC350DC04ADC@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.14\))
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:content-transfer-encoding:mime-version:subject:message-id:date
         :cc:to;
        bh=f7+Ji9iwyRin8bF/31Jh4PKZRcSeX5vOP4UH9FsYD94=;
        b=E5IdDBB4L/OKqkLFUHMZFbtWTcxOc2AoCuLv/N7tmC4Kl4h3rH+BIKEnx0ioKABbVV
         MlYIIxQL7uVuluHIw4Cx6+rNpjOcmTgOQbr+MFQpjOQrRW5+K3yYxi7ZiycD/0Y8xJQB
         GMadALZ1J9hFZyiZ3DCNNYmGocky3rwaAt8REDl3v7rGvDOoLUds5nO/C5PVVxHCPwY5
         sdXq31KX5j0rd7OX5vbVtzHRZwgV0Mn2y8VbPQabGNgtAFkdIw0oeqHwxn5zW8sNpFIr
         PHfNZ5QD9hyfFn+tg4yGecZPKkJNGEorZFlZ8k4Cx3KutFowGPB5/Ehd9FHgjkKEhOQx
         emYQ==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Yunhong Jiang <yunhjiang@ebay.com>

Hi, Simon & Julian,
	We noticed that on our kubernetes node utilizing IPVS, the =
estimation_timer() takes very long (>200sm as shown below). Such long =
delay on timer softirq causes long packet latency. =20

          <idle>-0     [007] dNH. 25652945.670814: softirq_raise: vec=3D1 =
[action=3DTIMER]
.....
          <idle>-0     [007] .Ns. 25652945.992273: softirq_exit: vec=3D1 =
[action=3DTIMER]

	The long latency is caused by the big service number (>50k) and =
large CPU number (>80 CPUs),

	We tried to move the timer function into a kernel thread so that =
it will not block the system and seems solves our problem. Is this the =
right direction? If yes, we will do more testing and send out the RFC =
patch. If not, can you give us some suggestion?

Thanks
=E2=80=94yunhong=20=
