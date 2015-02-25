From: Ruben Kerkhof <ruben@rubenkerkhof.com>
Subject: Standalone version of libipvs
Date: Wed, 25 Feb 2015 10:43:44 +0100
Message-ID: <BB41ACB6-F2C4-4C33-9FF4-D670B7E6228D@rubenkerkhof.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rubenkerkhof.com; s=google;
        h=from:content-type:content-transfer-encoding:subject:message-id:date
         :to:mime-version;
        bh=fSqUgiTT0RpgySA6VWSLvOprDZQ/bxrZPkhhP5yA/yo=;
        b=FTuu/9ON3YUgwzLHaY0oyIbF8agr3b8xMpYyTduJ1wrCEUaKsH7rKPnDyZ/Wd2vj1J
         oPZyK7lYDTOSawSwx3xoawgobEv+Rr9kWWUBwE0oTcY9TsQgEUz58BUPE5ZV6bFWGcmL
         TxKppD3B0fcyLALW24tVPViLDfdmWYLgXu1q0=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hi all,

I've been looking into IPVS for an internal project and have plans to write python bindings for libipvs.
Now I noticed that both ipvsadm and keepalived use their own internal version of it, with some small differences between them.

Since the library doesn't seem to change much and the API is reasonably stable, would you consider making it a separate project with a proper versioned soname?

Kind regards,

Ruben Kerkhof