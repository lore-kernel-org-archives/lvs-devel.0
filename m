From: Julius Volz <juliusv@google.com>
Subject: [PATCH 0/2] IPVS: Merge AH and ESP support into one file
Date: Fri, 22 Aug 2008 14:06:11 +0200
Message-ID: <1219406773-19357-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219406779; bh=HQLf7jIPqBUcUuCiDoy5xQOP7lM=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer;
	b=fIk6IFH7dzIjxNPJitHYi2WojCR7TpMCzBtTzmZ16gylpoarCoIxHoLxcwcYyaDSl
	KKAP/D2NRWi6jqpC23Y7w==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, vbusam@google.com, sven.wegener@stealer.net, brian.haley@hp.com

These patches remove the duplication between ip_vs_proto_ah.c and
ip_vs_proto_esp.c by merging the same functionality into one file,
ip_vs_proto_ah_esp.c.

The original files are almost 100% identical, except for names,
constants, etc., which either referenced AH or ESP. This was brought
up by Brian Haley when I duplicated even more in those files in the
IPVS IPv6 patches. Maybe there's some interest in keeping the files
apart though, so feel free to ignore this then.

Julius
