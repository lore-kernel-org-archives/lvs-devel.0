From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: lvs-users mailing list and archive dead?
Date: Sun, 23 Oct 2011 21:52:58 +0200
Message-ID: <4EA4709A.1050501@wpkg.org>
References: <4EA44C9F.4030104@wpkg.org> <e6ed933e-c1dc-4931-b97e-89dec46d8617@email.android.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=wpkg.org; h=message-id
	:date:from:mime-version:to:cc:subject:references:in-reply-to
	:content-type:content-transfer-encoding; s=default; bh=XCPKbMn9E
	OW8C74v/ch4RNteOag=; b=aK2xT5Uo551g06UZfP9okFe9gu4b61kAtJ7MVg9CB
	aKZ1vsc+E4rTWQxYEoH7td7ap9fuWrauTLDHP+qz2rlJg1yzfPBIwihRdiZOvJzO
	nQ43DB7z6dLbx1s/BLK+bujXyjYoLnuqSLJzvEwhRHQ0X/dhdx7OfM9eI5CVR3xF
	xc=
In-Reply-To: <e6ed933e-c1dc-4931-b97e-89dec46d8617@email.android.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Graeme Fowler <graeme@graemef.net>
Cc: lvs-devel@vger.kernel.org

On 23.10.2011 20:13, Graeme Fowler wrote:

> It still is, it's still live and is active.
>
> Can you not access it? Does the name resolve?

Ah, indeed it's alive.

I'm not able to resolve names from it from a largish German hosting 
provider, Hetzner.

The (IPv4) nameservers for graemef.net are:

ex.graemef.net has address 89.238.178.25
boom.graemef.net has address 82.113.154.29


# dig graemef.net @89.238.178.25

; <<>> DiG 9.7.3 <<>> graemef.net @89.238.178.25
;; global options: +cmd
;; connection timed out; no servers could be reached


# dig graemef.net @82.113.154.29

; <<>> DiG 9.7.3 <<>> graemef.net @82.113.154.29
;; global options: +cmd
;; connection timed out; no servers could be reached


On the other hand, ping works fine, so (some) connectivity works...




-- 
Tomasz Chmielewski
