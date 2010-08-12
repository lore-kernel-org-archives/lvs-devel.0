From: xiaoyu Du <tingsrain@gmail.com>
Subject: Re: [PATCH] IPVS : bugfix for ICMPv6 checksum calculation
Date: Thu, 12 Aug 2010 13:48:02 +0800
Message-ID: <AANLkTimAsoRSRVGy5ULHDTGJTdu_VZb-jJAoVNM8o2no@mail.gmail.com>
References: <AANLkTimQSppX5HzBoAcU73+7odFBJ8jXHBtszBO+8LVm@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:in-reply-to
         :references:date:message-id:subject:from:to:content-type;
        bh=ewZch/Frgcjbaxu16TNjj68vuBhGwtIUmxaRfxxQb2Q=;
        b=pF4NfbVTTFCo5oQ9J7cNe/PcN3ZPtNN10idArCSeOjiXuzhBcCtAM+ypIPYQrmf/Ak
         xUno2x8evOYdIGBbP3qa6FTMdKPMNDYmjhGEVV8R7gGdt7i1Wnni95PcaNnccXUUIbu8
         tRWDwjcYNp88iAxchEcnD2Yw3QLkfwmBrzRt8=
In-Reply-To: <AANLkTimQSppX5HzBoAcU73+7odFBJ8jXHBtszBO+8LVm@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

forgive my careless and poor english , "correct" should be "corrects".
