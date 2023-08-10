From: Sishuai Gong <sishuai.system@gmail.com>
Subject: Race over table->data in proc_do_sync_threshold()
Date: Wed, 9 Aug 2023 20:30:37 -0400
Message-ID: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3731.700.6\))
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1691627449; x=1692232249;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:from:from:to:cc:subject:date:message-id
         :reply-to;
        bh=NgSnc+u+kbp/QMsiSMo1lKUz4Qdpl315YK5X8DFb5ck=;
        b=ICtwK6cXoGKdAD2t5MqAhwnUcfiuQHSt6ZuVi/uRBsoK9+fMijN5qGaVKjksRl+i/e
         1YGevAuqKdHISPNR/FtzvAKlHNzdn9qN/OHMaj6JeKuDJ7NT5SODvVf3woqMo4VKo+cD
         2ZcniWn4WmORHx02OBTqR9+CDD8On1ecV/hK1dQ8ah3pTZkR06KqTJByjXdGLlcnyO7V
         j6QUbatXwu9qRoIpz3osyDalxuD3AvSputENrAE8k8NbqKMU7rlUeJQLu1P4JBNjJw8T
         cfoj1ecgbj+nnCKyuTnhhLMNSumwbZTGANnOY6hrE+WDJdVNRr4P8DNI/ivHuMa2JTcv
         /ZTg==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: horms@verge.net.au, ja@ssi.bg
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

Hi,

We observed races over (struct ctl_table *) table->data when two threads
are running proc_do_sync_threshold() in parallel, as shown below:

Thread-1			Thread-2
memcpy(val, valp, sizeof(val)); memcpy(valp, val, sizeof(val));

This race probably would mess up table->data. Is it better to add a lock?

Thanks
