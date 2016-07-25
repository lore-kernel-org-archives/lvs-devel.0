From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] lvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc)
 || svc == NULL
Date: Mon, 25 Jul 2016 10:27:46 +0900
Message-ID: <20160725012746.GE12825@verge.net.au>
References: <1469145341-15488-1-git-send-email-fgao@ikuai8.com>
 <alpine.LFD.2.11.1607220757100.1764@ja.home.ssi.bg>
 <20160722081143.GB29153@verge.net.au>
 <CA+6hz4qWTMXgpzOu3-uPv09mvT7pjxVmqKf4ApsqO=+W_dHOZA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1469410067; bh=H8JmReXo6EEtzgRzTUGNw4aOEDN/h/5+Py0uX3C6O/E=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=NRHc51HbU3rVb6hpf2PS78CuxBMrDPW9Qlhb/DWDcCA7ltE24vG2tmgH41wbbs/sk
	 0UBC5vLL9c3B3NNmwu3OaLS49aVgrIMLKaUk41OCzAf2eArcDALpeBntZtlqXXKEa1
	 QOM3uqf2ED9EHz9sv970SvwfpBZN4di/8RraxZkI=
Content-Disposition: inline
In-Reply-To: <CA+6hz4qWTMXgpzOu3-uPv09mvT7pjxVmqKf4ApsqO=+W_dHOZA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Feng Gao <gfree.wind@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Gao Feng <fgao@ikuai8.com.aqb.so>, wensong@linux-vs.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Fri, Jul 22, 2016 at 06:52:30PM +0800, Feng Gao wrote:
> Thanks Simon.
> This commit is accepted ?

Hi Feng,

it is now.

I have pushed it to the ipvs-next tree and it should appear in net-next
within the next 24 hours. Baring a calamity it should appear in the v4.9
release.
