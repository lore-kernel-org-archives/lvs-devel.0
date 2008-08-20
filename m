From: Vince Busam <vbusam@google.com>
Subject: Re: [patch] ipvsadm: use strtoul to convert ip addresses from hex
Date: Wed, 20 Aug 2008 10:46:24 -0700
Message-ID: <48AC5870.9050000@google.com>
References: <20080820054415.GA31393@verge.net.au> <f4845fc0808200330lc1cad87ya94eb73da9b4c175@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219254390; bh=q2i6oqHo2Yx6GDEwfg2pWfKjjtk=;
	h=DomainKey-Signature:Message-ID:Date:From:User-Agent:MIME-Version:
	 To:CC:Subject:References:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding; b=mZOKLLvYyqgJQ82R/KjIbHk3LaKbqaaroKXFU
	yKm/wG02oPupRbX1OqKRFUsLdSQN0GWeS1g5OzrfaH9p9jJ/A==
In-Reply-To: <f4845fc0808200330lc1cad87ya94eb73da9b4c175@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org

Julius Volz wrote:
> On Wed, Aug 20, 2008 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote:
>> The ip addresses that come out of /proc/net/ip_vs_conn as integers
>> are in hex not decimal.
> 
> Thanks for this fix! I'm sure Vince will release a new version with
> this once there is sunlight in his timezone :)

A new version, which also fixes a bug in sorting IPv6 addresses, is up 
at http://sixpak.org/vince/google/ipvsadm/

Vince
