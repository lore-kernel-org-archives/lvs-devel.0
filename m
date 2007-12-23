From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: A question regarding Load Balancer in LVS and the ARP problem
Date: Sun, 23 Dec 2007 17:20:51 +0200
Message-ID: <31436f4a0712230720k59f19455q346f0bd4fa0023d4@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:message-id:date:from:to:subject:mime-version:content-type:content-transfer-encoding:content-disposition;
        bh=JcNku3geIx8fORl79PuiazRZ0PAtub5QOF7HMcXtVgg=;
        b=VAMVV3nsFLSs4Ozl9NZLYco2TyaqulqJ2JopfwCid1qdv0bDBHCYJA2LRHp1tas4zhoeZ2ExdYUkrnlxt+qJTR9RX51h70zFBeiOIr/9TLvc7PqWziuZtc3vXLvpBPX6iOmPS/U3mmWy3ARnZndyBYIyL3sgnV9bb+0BO0qI+zA=
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hello,
It is suggested to configure the VIP on the real servers , when using
DR (Direct Routing), using the loopback device
(lo:0).

I saw it in a couple of places (including LVS wiki).

My question is : suppose I have 2 NICs on each real server. Is there
any advantage of
configuring the VIP on the loopback device against configuring it on eth1 ?
should configuring the VIP on eth1 work ?

Best,
David S.
