From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: how does LVS persistence work?
Date: Tue, 18 Oct 2011 23:26:43 +0200
Message-ID: <4E9DEF13.3040106@wpkg.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=wpkg.org; h=message-id
	:date:from:mime-version:to:subject:content-type
	:content-transfer-encoding; s=default; bh=mRVKSYPaIqHE8eYUhsuDoQ
	RWWVU=; b=jcV0iYfFrzQA/zDxOig04UNYwLGumua2texN+LoeUi2iqYU1eb+UUt
	QfPuZ4Ej2GDI8w7fsJEOhrtChGCVAt3K8bsq+BCfz7ZbN3uFvU2WPeJlwpj4kP3H
	WdvwFWJcSmJE9Lrsk1AYMiDNli3hs17o1PiwC3OlEncHBtezHmj9Q=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: lvs-devel@vger.kernel.org

According to http://www.linuxvirtualserver.org/docs/persistence.html:

	In the persistent port, when a client first accesses the
	service, LinuxDirector will create a connection template
	between the given client and the selected server, then create
	an entry for the connection in the hash table. The template
	expires in a configurable time, and the template won't expire
	until all its connections expire.


Suppose I have two real servers and persistence set to 30 minutes.


How will LVS persistence behave for a client which first connects at 01:00?

1) persistence is always "first connected + 30 minutes".

When the client connects at 01:00, LVS sets persistence to 30 minutes.
All connections from this client, between 01:00-01:30 will be directed 
to one server.
At ~01:31, persistence will expire and will be set again; it's possible 
that the client will hit the other server, even though the last 
connection was made at 01:29.

Meaning - if the client makes one short connection every 25 minutes and 
persistence is set to 30 minutes, the chances are it will hit a 
different server (almost) every time.

lvs-devel@vger.kernel.org
2) persistence is always extended and is "last connection + 30 minutes".

In other words - if the client makes one short connection every 25 
minutes and persistence is set to 30 minutes, it is practically 
guaranteed the client will always hit the same server.


Which one is true, 1) or 2)?



PS. http://lists.graemef.net/mailman/listinfo/lvs-users seems dead?


-- 
Tomasz Chmielewski
http://wpkg.org
