From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [lvs-users] Micro ipvsadm patch
Date: Fri, 20 Mar 2020 13:31:37 +0100
Message-ID: <20200320133137.3cc59704@carbon>
References: <CAH57y_TcVNdCe7ciAXX85HzWXPhWgUWvXn2f7r8yWjM2TUNecQ@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1584707541;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=q59I6+lX0Di4/mSsiaIDK7x6zwRbWQxto0rO5l0DxN4=;
        b=fEhWEmfEo+e9DE7z9/7twK9x+bACUpYHBVoiRKB9cBTbCcswM6rbB1qBa0Vini9SLiTvb+
        APKrc98jRtUzZcl11TcoRCdnOqKLs1X8/2zBK9tJaqNcON8gILOjk2kfEJJDXneTRrG/zm
        GpbWvo8+7O+HNLwQBiOFILN9cHV8j1M=
In-Reply-To: <CAH57y_TcVNdCe7ciAXX85HzWXPhWgUWvXn2f7r8yWjM2TUNecQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Alexander Petrovsky <askjuise@gmail.com>
Cc: "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, brouer@redhat.com, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Wed, 11 Mar 2020 15:05:58 +0300
Alexander Petrovsky <askjuise@gmail.com> wrote:

> Hello!
> 
> This micro ipvsadm patch fixes wrong (negative) FWMARK values
> representation:
> 
> # ipvsadm -L -f 2882430849
> Prot LocalAddress:Port Scheduler Flags
>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn  
> FWM  -1412536447 wlc
>   -> abc.my.host.net. Tunnel  1      0          0  
> 

Hi Alexander,

Your patch submission does not follow all the procedures, but given
this is fairly trivial, and Julian didn't object, I went ahead and
applied the patch with (your SoB and credit to you), here:

https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=e61c8cdd1dcad

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

