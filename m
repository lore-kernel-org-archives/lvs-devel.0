From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: Re: [PATCH] ldirectord: Add the ability to service check Memcached
Date: Sun, 23 Dec 2012 18:53:17 +0900 (JST)
Message-ID: <20121223.185317.1568838937885763856.sohgo@sohgo.dyndns.org>
References: <CAFVJ3VcOxav65-dwPjHXZuj29KFfZ-ntj0WfZj9k56wMp7zqCA@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAFVJ3VcOxav65-dwPjHXZuj29KFfZ-ntj0WfZj9k56wMp7zqCA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: caleb.anthony@gmail.com
Cc: lvs-devel@vger.kernel.org, horms@verge.net.au


From: Caleb Anthony <caleb.anthony@gmail.com>
|
> Hello.
> 
> In my organization we have multiple Memcached servers that we load
> balance with IPVS. I needed the ability to service check them and I
> didn't want to settle for the "connect" and "simpletcp" wouldn't work
> with the telnet interface or the Memcached protocol. So I added the
> ability for ldirectord to natively service check a Memcached instance.
> 
> Once this patch is applied, you will need the Memcached Perl module
> installed for the service check to function.
> 
> http://search.cpan.org/~dormando/Cache-Memcached-1.30/
> 
> To configure ldirectord to service check Memcached, set the service
> line to memcached.
> 
> service = memcached
> 
> Additionally, you can configure the key value pair to store in
> Memcached by configuring the request line to "key:value".
> 
> request = "key:value"
> 
> If request is not configured, a default of "ldirectord:ldirectord" will be used.
> 
> I'm open to any comments, or suggestions. Also, if you feel that this
> feature is beneficial I would appreciate if it was merged into the
> mainline.
> 
> Thanks.

nice patch!

