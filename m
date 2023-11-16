Return-Path: <lvs-devel-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7426BC54FB9
	for <lvs-devel@archiver.kernel.org>; Thu, 16 Nov 2023 13:12:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230182AbjKPNMa (ORCPT <rfc822;lvs-devel@archiver.kernel.org>);
        Thu, 16 Nov 2023 08:12:30 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56042 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229919AbjKPNM3 (ORCPT
        <rfc822;lvs-devel@vger.kernel.org>); Thu, 16 Nov 2023 08:12:29 -0500
Received: from mail-pl1-x631.google.com (mail-pl1-x631.google.com [IPv6:2607:f8b0:4864:20::631])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C896B182
        for <lvs-devel@vger.kernel.org>; Thu, 16 Nov 2023 05:12:26 -0800 (PST)
Received: by mail-pl1-x631.google.com with SMTP id d9443c01a7336-1cc58219376so7049815ad.1
        for <lvs-devel@vger.kernel.org>; Thu, 16 Nov 2023 05:12:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1700140346; x=1700745146; darn=vger.kernel.org;
        h=mime-version:date:subject:to:reply-to:message-id:from:from:to:cc
         :subject:date:message-id:reply-to;
        bh=l9eK3ocpMbY4mbOKT8EatthY1rZTGU14/x7HKUGp56A=;
        b=Ym0ITXgOuAZnMTCbPNC3oZg4uor4675hfDrw2MsGkkmHIEzjGtdmM6ake5pjTJLG04
         vIKGiVjStfBD8ED+jzrPZq1NWGdSS4nBGWAPwK9ldy8ARwWgUtvWYQsmdbPjqe49Pugb
         Kvybjipm8LgEljL8mUFlwvi6lv3ADBh7L1j0wDFfmu1VNHmQJIYNIhGoifgUIrydwCyZ
         fTy4RBxMJjwi1q4Ijf4YuBpBdl5sRYvMxvblYES5ggfc5qlq46wZNr3DoPTIF6+2ZLw6
         hAlM86Bvi7gxfWhjoMGj8p9hCOp5JHNN/0/n/eZdsgcWv5zYkVPVKKRbhxTMEkRh9o9V
         OdZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700140346; x=1700745146;
        h=mime-version:date:subject:to:reply-to:message-id:from
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=l9eK3ocpMbY4mbOKT8EatthY1rZTGU14/x7HKUGp56A=;
        b=nIQTXb4suy0hKPQ6bEwJgtl0Ssny/GCOF1dUM9yCn7pZBgT6RMjMQlFG6C1Rpo4DLP
         A7pydiGBWxg3Qa+tWOzisNgTeIrRROpeZmcIlvxIetbjaJyecdnNJqEyQ+VXywxJzYRa
         ev5qG4oxWXlQ+AGK81GNKcXM4DQHNtdaoR5vKUvmZubi4+T80reQTFzj4/qxQAjLdOPF
         40Ak2nnZxxGUFghcInRkFu3CwoIl5XZlsA4bziyI5XuQqWA0vcsmlnBna92++ltbaCfu
         673Yldh0ZUsSmHUIlhL2GOFhwOY9AlSxxWfRZVtojXTjjLklNsPcOo+rs/bX65RYUfLJ
         qBTQ==
X-Gm-Message-State: AOJu0YwOWMy3ryt68Oi7XIaouIDlgwgBv5uMZoCyR7ljG1FLb2XLIfOL
        M0H7td1QsCBIggwf42LvGSJb5SFrFJs=
X-Google-Smtp-Source: AGHT+IFWN4cfCwQ+WeBNLvAGNaV6N57/KJpA4N69HNVaBxc1LcKNM++5QFISEjmFvMag+YlKVtTKZA==
X-Received: by 2002:a17:902:694a:b0:1cc:bfb4:2dca with SMTP id k10-20020a170902694a00b001ccbfb42dcamr8173996plt.6.1700140345794;
        Thu, 16 Nov 2023 05:12:25 -0800 (PST)
Received: from [198.135.52.44] ([198.135.52.44])
        by smtp.gmail.com with ESMTPSA id o2-20020a1709026b0200b001a98f844e60sm9107984plk.263.2023.11.16.05.12.24
        for <lvs-devel@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2023 05:12:25 -0800 (PST)
From:   Peter Wilson <joykanini15@gmail.com>
X-Google-Original-From: Peter Wilson <info@alrigga.com>
Message-ID: <17a2f7aac05ce1361d9b91c576d52d08a3b163526b2c94dca1067dcda9534571@mx.google.com>
Reply-To: mrmo754abc@gmail.com
To:     lvs-devel@vger.kernel.org
Subject: :once again
Date:   Thu, 16 Nov 2023 05:12:14 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Precedence: bulk
List-ID: <lvs-devel.vger.kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org

Hello lvs-devel,

Are you Thinking of starting a new project or expanding your business? We can fund it. Terms and Conditions Apply.

Regards,
Peter Wilson
