From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: Re: [PATCH 0/2] netfilter: allow tab character in SIP headers
Date: Wed, 7 Sep 2016 22:00:13 +0200
Message-ID: <CANHHuCV4p0MmYTWL4A6y6p0YLcaiwPJX04ZwifrMxXsAn4_WCw@mail.gmail.com>
References: <20160830165222.pAgDVdNXQ%marcoangaroni@gmail.com> <20160907115654.GA4460@salvia>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=f2rQs1fFmJK0TFE3RM6Fauf6sXniIDBmafvYahXEQw0=;
        b=o4fbjrriepQtW1WbDoSPfW0alf0kSMY1CyD5/1wlWJfktea99+rnLjaqPCWDxdeUDO
         CV1sZEkU0XA48jmjfA+tuG6eLkEM6LxLS1iyIiF9A2phDf3GCKlDIg5WwuKbb+HB0u3O
         sXa/r4VVzLG2AIBkQiYxg3QtebBafy5yURe2wvwY4mfyq15UNFonkio4+WSW/5qHtLGf
         3C2JElk9ydr3NheMxPE76ssqvvH9Sy8qqUe23E6AxmAM5onjxjHBr6Sttlywgl+fxkyx
         0/lrhgJNzHziwO/tdBZdoXhhjv4WDdbApNWiwJAB4IdpwySw2g/DXCcPdyeMcf/YoV7l
         aX2g==
In-Reply-To: <20160907115654.GA4460@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

2016-09-07 13:56 GMT+02:00 Pablo Neira Ayuso <pablo@netfilter.org>:
> Applied this one too. I got confused because patch 0/x is usually the
> cover letter, I suggest you don't use 0/x for patch series in the future.

Understood, thanks.
