From: Alex Gartrell <agartrell@fb.com>
Subject: Re: Standalone version of libipvs
Date: Wed, 25 Feb 2015 16:05:55 +0000
Message-ID: <AF7C7217-774F-40A4-AB1F-EF58354F2C37@fb.com>
References: <BB41ACB6-F2C4-4C33-9FF4-D670B7E6228D@rubenkerkhof.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=z8IaF4eIMk/GGVXgGmG3l+OzGicr0ZFq/acvSU0T4Qc=;
 b=Nu9JLDldP91BnItA8a9tAYP3iQIPBoHVNlDlFb1wZZXt3RHsohIq7tf0/6r0nFlG4rl1
 UuPa06e4JYJ6woY6ovG/iKHc7RtpdghwuEV8gNBn8ZiuME8hSTao2XXfLD3dYFUHNhuu
 RcRsGgDxuDjrEZvRTadCk20A2rj0jld2L6Q= 
In-Reply-To: <BB41ACB6-F2C4-4C33-9FF4-D670B7E6228D@rubenkerkhof.com>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Ruben Kerkhof <ruben@rubenkerkhof.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Fwiw, we (at Facebook) have a python-only ipvs library that I'm fairly certain we can give away if there's interest.  There isn't really a logical place to put it at the moment though.

> On Feb 25, 2015, at 1:43 AM, Ruben Kerkhof <ruben@rubenkerkhof.com> wrote:
> 
> Hi all,
> 
> I've been looking into IPVS for an internal project and have plans to write python bindings for libipvs.
> Now I noticed that both ipvsadm and keepalived use their own internal version of it, with some small differences between them.
> 
> Since the library doesn't seem to change much and the API is reasonably stable, would you consider making it a separate project with a proper versioned soname?
> 
> Kind regards,
> 
> Ruben Kerkhof--
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
