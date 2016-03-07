From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: correct initial offset of Call-ID header search in
 SIP persistence engine
Date: Mon, 7 Mar 2016 11:57:23 +0900
Message-ID: <20160307025723.GA3292@verge.net.au>
References: <56dabe8a.wEnEwnUQ23/U/p/3%marcoangaroni@gmail.com>
 <alpine.LFD.2.11.1603051345210.1715@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1457319445; bh=S1H7ftW0R8Ky87RnjWSj82tVF7FWVkp7GSwEiWq1nCk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=oUjABnZzOLFmd+kE+bfhwuxTa3F6AgF2nApiMMm0GWtGxuv9R09PTPsniridUv989
	 R1hZwpSM9cow8seai9VeZL/Klf4yNvnwpQ+vCEYOmml+BJtTllvV+JFRgcncQ/vREB
	 FyeXyoc/32WaNPxpuwfZ3HbRjUVKVQIM/sGq9jJ8=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1603051345210.1715@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Marco Angaroni <marcoangaroni@gmail.com>, lvs-devel@vger.kernel.org

On Sat, Mar 05, 2016 at 01:47:04PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 5 Mar 2016, Marco Angaroni wrote:
> 
> > The IPVS SIP persistence engine is not able to parse the SIP header
> > "Call-ID" when such header is inserted in the first positions of
> > the SIP message.
> > 
> > When IPVS is configured with "--pe sip" option, like for example:
> > ipvsadm -A -u 1.2.3.4:5060 -s rr --pe sip -p 120 -o
> > some particular messages (see below for details) do not create entries
> > in the connection template table, which can be listed with:
> > ipvsadm -Lcn --persistent-conn
> > 
> > Problematic SIP messages are SIP responses having "Call-ID" header
> > positioned just after message first line:
> > SIP/2.0 200 OK
> > [Call-ID header here]
> > [rest of the headers]
> > 
> > When "Call-ID" header is positioned down (after a few other headers)
> > it is correctly recognized.
> > 
> > This is due to the data offset used in get_callid function call inside
> > ip_vs_pe_sip.c file: since dptr already points to the start of the 
> > SIP message, the value of dataoff should be initially 0. 
> > Otherwise the header is searched starting from some bytes after the 
> > first character of the SIP message.
> > 
> > Fixes: 758ff0338722 ("IPVS: sip persistence engine")
> > Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> 
> 	Looks good to me. Simon, please apply.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have tentatively queued this up as a fix for v4.5.
