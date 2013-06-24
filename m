From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] ipvs: add sync_persist_mode flag
Date: Mon, 24 Jun 2013 17:37:09 +0300
Message-ID: <51C85995.1060500@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com> <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <51C5887A.1070301@gmail.com> <alpine.LFD.2.00.1306221510100.1577@ja.ssi.bg> <51C612F2.6080500@gmail.com> <alpine.LFD.2.00.1306231108450.1584@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=wAYm/zlE0lVo33MkGaZCn4/Pzy1TkGCnnB73H81lUvQ=;
        b=qug0dWEE5MCe7HO9th5LzbAZ/s1PBUZ3FooD5HqYOO6dtQxgHRB2FMnSkwX9F4Q/58
         iDPDY7QT5nglissQm+fmrkc9ZBUSYfSxe9bOsplimb7L11NT0M8WKP8Ju9OrKyiGvRqJ
         pqO2C7P6MaYW2o0Cr3EabO/ZFrOXwOZnkwHvHmNlRvG/qdY8xEU/LEtfh98gnT7U/xIq
         LzNH5WUgpCKEbXAesRN6jNLa/VKHuotgMB5owOTBvgRSIh9CYSo4xjU/aaxQSjtBvJ5z
         gMvLEqDn6KJJrd6O6pauXh+ZOe7F8j1IK8D/G7gpZmjHc8M8pkLO9xGtAeJQlk4qRs5n
         OhtA==
In-Reply-To: <alpine.LFD.2.00.1306231108450.1584@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

Pair of LVS servers with a modified kernel worked under load for several 
days without any problems.

I completed several additional tests. I analyzed the traffic to the LVS 
servers using tcpdump. There is not SYN or RST packets spike at the time 
of migration of IP address. Thus, most of the connections have continued 
to operate normally. I also once again made sure that most of clients 
remain on the same real servers.

Seems like sync_persist_mode combined with sloppy_tcp works fine.


Regards,
Aleksey
