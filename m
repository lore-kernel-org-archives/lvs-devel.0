From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: RE: Re: Fwd: LVS on local node
Date: Fri, 23 Jul 2010 01:37:30 +0400
Message-ID: <188211279834651@web111.yandex.ru>
References: <20100723010102.121uPPJ1@mxfront8.mail.yandex.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex.ru; s=mail;
	t=1279834651; bh=Rs0juisFR8+9tiEKVyA4nc62Bt4Wgt2gfA4KpnD3eB4=;
	h=From:To:Cc:In-Reply-To:References:Subject:MIME-Version:Message-Id:
	 Date:Content-Transfer-Encoding:Content-Type;
	b=Okq/pbyY+K9427IR4hQNwUSsX+do7gzl45IZ55zETU4qEZE0C45ht2RGZCw/mDD5Y
	 FGG4lH3b16K2BiMYJ7UCPjtjjTIhR3F8+sLN4YHqEAmo9VoZanSjCxcrRME83D2c96
	 hlFnc+4Cu8bvQxz+Pn8fisl1Z1D6f69XLXtnnyzY=
In-Reply-To: <20100723010102.121uPPJ1@mxfront8.mail.yandex.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Graeme Fowler <graeme@graemef.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org



23.07.10, 01:01, "Graeme Fowler" <graeme@graemef.net>:

> Hi
>  
>  Technically keepalived is not LVS. It's a monitoring/mgmt app which can manage an LVS according to health-check logic. LVS by itself cannot "detect" any form of service failure - it's a fancy router with special rules.
>  
>  Graeme.
>  

Ah, ok. Then with iptables I can write keepalived app to insert/remove rules.
Is there interface to iptables for dynamically turn on/off rules without inserting and removing them from the table? 
