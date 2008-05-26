From: "Julius Volz" <juliusv@google.com>
Subject: Re: First IPv6 support for IPVS and ipvsadm
Date: Mon, 26 May 2008 20:49:33 +0200
Message-ID: <f4845fc0805261149o625b1ba7g7dbf8e307bd83c7d@mail.gmail.com>
References: <f4845fc0805230659o5464eb15i131790df8443349d@mail.gmail.com>
	 <Pine.LNX.4.64.0805230835510.27885@wm7d.net>
	 <f4845fc0805260839v3bbe7fder2507cff8ef006c4@mail.gmail.com>
	 <Pine.LNX.4.64.0805261102190.17875@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1211827775; bh=KlUmKWmtPlCl77z8UKOL5AjZr84=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=PAYwrk+po+ieOWL9hvrmnGdxo1y7lwao
	d1U0oC5qZKJYpTbtnpv17VLXDD+y6P5D6Xqrc7XbxGWkg+tGpBezzA==
In-Reply-To: <Pine.LNX.4.64.0805261102190.17875@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: lvs-devel@vger.kernel.org

On Mon, May 26, 2008 at 8:04 PM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
>> Thanks! I hope breaking the userspace<->kernel interface is ok for
>> this?
>
> sure. first step is to get it to work at all. Getting it to work well is
> another step.

Yes. But this particular bit is not about dirty first and clean later,
the interface breakage would be permanent.

> you should cc Horms individually. He doesn't respond a whole lot lately

I did with this last mail. And noticed that, too...

Julius

-- 
Google Switzerland GmbH
