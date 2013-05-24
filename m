From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 24 May 2013 19:18:51 +0300
Message-ID: <519F92EB.4080509@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=AGNTvceEKR4U0QOuhx0se8RAdhsWIdYFfoh/KnIOkh8=;
        b=AxPjCJwk7X3hcLIKZP//9UZCur5j7M8ghsxXuO5Smq4ukRWrrMQLg6L5SnUDsZcJmD
         6z0mkfACDH8HQOMLYzCzeeGMCiTZRI79CDlTAzaSyjUqz15qS9HaY0LEMXfJXWj0fwyn
         9ACwLqHnwikOWfjj8MfrcG05aMqoLZw480YGg/a/lMbrhve7PbnnMPkoq8iNX/PoFxz/
         pJ232e507HCoTA6ZJFbJh/cpw+ulDCyfS6/+QSqCNZDt+uzoreO8KY7PPxQiS3bMaZ0S
         bFpKGr3MtFXemtYEqJcwVoXewZBOxYN0ocMsyqVyQox9R7c0YQm1Lh3r9qqmZXc3R4/q
         5fww==
In-Reply-To: <20130524151408.GM264@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On 24.05.2013 18:14, Alexander Frolkin wrote:
> Hi,
>
>>> 1.  Sloppy TCP handling.  When enabled (net.ipv4.vs.sloppy_tcp=1,
>>> default 0), it allows IPVS to create a TCP connection state on any TCP
>>> packet, not just a SYN.  This allows connections to fail over to a
>>> different director (our plan is to run multiple directors active-active)
>>> without being reset.
>> 	For most of the connectoins the backup server
>> should get a sync messages in time, so it should be able
>> to find existing connection in correct state, usually
>> established. By using persistence the chances to
>> hit the right real server in backup are increased.
> We have a number of directors in active-active mode, we don't have any
> kind of state sync.  My understanding is that the state sync daemon only
> supports an active-backup configuration.  In our configuration it would
> have to be sending out updates and receiving updates from other servers
> at the same time.  Even if this works, we don't want a connection on one
> server creating state on all the servers in the cluster, because that
> would be a waste of memory most of the time.  Also, state sync
> introduces a race condition which doesn't exist without state sync.

I'm sorry for interrupting your conversation. Actually sync daemon send 
updates via multicast. So it is enough to run two processes on each 
server. One in the Master mode and second in the Backup mode. In theory 
it is possible to synchronize a large number of servers. In fact, in our 
experience, it is very dangerous to synchronize 16 node LVS cluster. 
During a typical syn flood all servers will runs out of memory unless 
you have 512GB of RAM in each node. For example, we observed the 
consumption of more than 30 GB of memory on each server during syn flood 
(without connections sync). Unfortunately sync more than three - four 
servers with each other is very expensive.

> It's not about imbalance, it's just about running a number of
> independent directors, with no state sync, but with the ability to fail
> over from one to another.
>

May be better to modify the sync algorithm to synchronize only 
persistence templates for these specific cases? Is it possible at all?


Aleksey
