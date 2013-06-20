From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 20 Jun 2013 20:02:46 +0300
Message-ID: <51C335B6.2000202@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com> <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <alpine.LFD.2.00.1306192221400.1823@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=gUPgpYscAPhQ2AycNkjeF/t+QAaa3HRvXQO7IuugFkA=;
        b=poPnXcUQ4af7afNURs5rTMyEaM3giLjCvLOunl7JXIvmmI2xzZhj44h3C5mNyOyaU8
         yTR1WRapysSB8Ch5My40ub4F2ImH++DdMEdk9GqwXyqH5UXzOMkeAF0FUuTRYz/GRTe2
         rcey8Fea4UE/VEwGybYHBQ0ccNaKVSpAGE5RY6olnmRE2eTMrbi5V1dYiTRjbewWdnjH
         8vz6YN3pocq55nY6FVDnwdbpdPY+7bX8kPJXV637tLeHJsx5sWMTwqeN9hEC2M5Tzqlw
         yD8NlH0zf0vJ1E6mDE1Z9v4YV+jMr/hDjzxMUWCwdxWRCEFO62AzwHo5ddOTt+8rX63M
         XSiw==
In-Reply-To: <alpine.LFD.2.00.1306192221400.1823@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

I'm trying to calculate how much memory will be needed to synchronize 
the persistent templates across the entire cluster. How much memory 
consumes one persistent template?

Aleksey
