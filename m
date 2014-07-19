From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Sun, 20 Jul 2014 01:59:31 +0300
Message-ID: <CANZNk83yhnbw0c77UPnisaJr8AO8XtmUon78vEKGe=PBDrfWMw@mail.gmail.com>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
	<CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=WB9j393R6Ir6W+jPv4es0HNuYTnqZGhoXkP1J/K4qP4=;
        b=mvzZsVxXd+FCR4wf5Y7s2wsUrRmUdcVeidSA0XZNq2pvnAYWF8md7b9pF1KP7mA3Mh
         7LBF69fF0GB0Fy2QYx0SA3EgF1ubpssapIJgm00xwYuleKYI6TzdpDlHWfWv7MROIevj
         kVMCOGMOVOtOfi4XSCvl974FCfObK9EbGMuKuC7tpQvOe7ptXUiFBGDY4TACSmVkHzZ1
         ZAUjmtZopz13DMEC6Ko1B1o3lXnQw1WbLRNWZI6+9rgDZINePL53TVETNi/WwgLWEp+1
         uFIRn9vBb1+wBsXn7AmNIkKaBilXO4lqCItIUM1U89yR8mpa37fL7o3xbe4s60kf4+vt
         XgDw==
In-Reply-To: <CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, dcb314@hotmail.com, David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu, Patrick McHardy <kaber@trash.net>, pablo@netfilter.org, Simon Horman <horms@verge.net.au>, wensong@linux-vs.org

2014-07-19 0:06 GMT+03:00 Andrey Utkin <andrey.krieger.utkin@gmail.com>:
> What about static check at compilation time?
>
> #if (DAEMON_ARG_LEN > MAX_ARG_LEN) \
>  || (SERVICE_ARG_LEN > MAX_ARG_LEN) \
>  || (SVCDEST_ARG_LEN > MAX_ARG_LEN)
> #error MAX_ARG_LEN exceeded in set_arglen table
> #endif

This approach doesn't work, looks because sizeof() values are not
calculated at preprocessing stage.

-- 
Andrey Utkin
