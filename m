From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Sun, 20 Jul 2014 02:03:21 +0300
Message-ID: <CANZNk83+o9Sc2rir3_2_aTgE65VadY3104a9ve8EMvXWv2ZzUg@mail.gmail.com>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
	<CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
	<CANZNk83yhnbw0c77UPnisaJr8AO8XtmUon78vEKGe=PBDrfWMw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=WwgaNXmTD5JtrIOjws9kk8fpIlUCLcEF41OmrQgAv9A=;
        b=eNZiPPe78vOTbjFpSsCfMJ+jbHzwiKYURzrmHZF51WpEsBAwBJZFCJj6JBoS7tByaX
         VbStTdF8Rcin5hvz3REre7ThvlIqJOzS4vR2k9PGhbjEeiFKpiW7MrzObV0bhb7m0jvE
         /1a4jOt0/LtUapM0RbJeLCbzShbjm4hysAfNeqxCiOzVB4rCOwcvB55b5rEtTBUdcz1W
         qkHQwVvV5veOurDwfn1KlcdD4beLdhNDABQK7JuWNzQw7zOPqx1j6RNtKa2/o5rigF6q
         JxQinat+IkEjZh0ZZt4JfP+cWmDiz0S0d59YZa3IO2skbETOmI7w67t2vt62Qa/x4v7b
         tbTQ==
In-Reply-To: <CANZNk83yhnbw0c77UPnisaJr8AO8XtmUon78vEKGe=PBDrfWMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, dcb314@hotmail.com, David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu, Patrick McHardy <kaber@trash.net>, pablo@netfilter.org, Simon Horman <horms@verge.net.au>, wensong@linux-vs.org

2014-07-20 1:59 GMT+03:00 Andrey Utkin <andrey.krieger.utkin@gmail.com>:
> This approach doesn't work, looks because sizeof() values are not
> calculated at preprocessing stage.

What about adding equivalent BUG_ON() statement to __init
ip_vs_register_nl_ioctl(), which "registers" do_ip_vs_set_ctl()
callback?

-- 
Andrey Utkin
