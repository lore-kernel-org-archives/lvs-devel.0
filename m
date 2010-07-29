From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: Re: [patch][bug][ldirectord] underscore in a servicename
Date: Thu, 29 Jul 2010 11:59:42 +0900 (JST)
Message-ID: <20100729.115942.232765930.sohgo@sohgo.dyndns.org>
References: <20100728.223052.102572767.sohgo@sohgo.dyndns.org>
	<20100728234119.GA4868@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100728234119.GA4868@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org


From: Simon Horman <horms@verge.net.au>
|
> On Wed, Jul 28, 2010 at 10:30:52PM +0900, Sohgo Takeuchi wrote:
>> 
>> Hi,
>> 
>> I found a bug in ldirectord and attach a patch to fix this
>> problem to this E-mail.
>> 
>> If a underscore is contained in a service-name of
>> hostname:servicename
>> (ex. real=realserver.example.com:pipe_server), it leads to a
>> configuration error.
> 
> Thanks Takeuchi-san, I have applied the change as follows.

Thank you!

--
Sohgo Takeuchi
