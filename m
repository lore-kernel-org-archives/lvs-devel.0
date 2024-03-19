Received: from mail-qk1-f178.google.com (mail-qk1-f178.google.com [209.85.222.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63E7C364D4;
	Tue, 19 Mar 2024 22:49:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710888562; cv=none; b=V7zhFErlFWYOo4Wx//Polle13xWgHYhQ0Sx/qN8myYIx3aBeHx+Yk/1MS/kIMDJBYuov/pucPbak2nzSoNnD9iUYEPuax8lta6fWaIu3rsRDQ1ivlbyYouVH/iSe5NjBGpJ60bS7boZZncxFM9dQvCFHrOGR1S/9WguK9DEa1kQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710888562; c=relaxed/simple;
	bh=hY7Qrm6Z+Ri/tqAFiaNgt/KD2fehu+eG9GkAkB/P1nE=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Cc:Content-Type; b=WjzwcPAjBZkQWg/9y8e3kfOPqP4MA2MHec6AfHIXWDnIc055K80fLl/AsaIfpkLYaKzpHxwdMTx76JdT1OSs8wvNKBADcki4pZafSCDRpCe0MuIXOzivSA/RJfr3BsYUOILZbh2e8TvSh4TxGG5FyUEw8L8pVxCTO1fUyb1cFPM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=FJ0FEE3w; arc=none smtp.client-ip=209.85.222.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FJ0FEE3w"
Received: by mail-qk1-f178.google.com with SMTP id af79cd13be357-789db18e169so455555785a.1;
        Tue, 19 Mar 2024 15:49:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1710888560; x=1711493360; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:subject:from:to:content-language
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=V+3XOLRqQvOEeLiRjJAh8LJnrrAM0/tDEQfJD1xUeSg=;
        b=FJ0FEE3w9+OfCwpxGTuOVDMOsefU55Tm/qO7JCVuA7oCB01ddEoi/s9rCPtA6bnpTH
         O38Wn+Np53Xy0B01kEAHS1bs+cWZJygylsNYMkNZWwhtuxSPgLbT8/AVF6AO+9tE7Nav
         eCKk309WmskDRnjCl8EyBk6bB4K7T27hEOBC6i9D58R6EMG4HeVN1t0O2nBDelU4WCOr
         RiRAJRAE27dgR1Me5513BW74WYQvjR4Eo2qN01/aV2sdmNKqI7axCWuFoAb1a+/GX1Le
         uAHYowrwyZ2PtY6ut+kMZUqb843J+QEqzuPuJf8mZpRZqLtk9nfqcBfwR+EnoH/R0ajv
         /Frg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1710888560; x=1711493360;
        h=content-transfer-encoding:cc:subject:from:to:content-language
         :user-agent:mime-version:date:message-id:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to;
        bh=V+3XOLRqQvOEeLiRjJAh8LJnrrAM0/tDEQfJD1xUeSg=;
        b=R+0K6OnUtzhQY0+Bipdpu4yQcmpONAGcg0elAYSj8dd0Ra8oBR4hmNxCHtOkS9fNU7
         rgxDMqOt4m/mYMLcGDl//85xCI9u1mJrjFlQjCC15EDHpGOKHN3MAREEYx51Q2tKvSt0
         OkO5tx8Hyhhl/5cKhTniBUkk4snFgPE45WbDqCMj3GLSGWxzJ3jExBZVQyIC6Bw05KJo
         YVuO6FoXhUv9YKKO5apdKe3kzCwWEBBqBOKwuB/KiLbrAhfdIvq+ZE7trv3wItFRhyAs
         crqtmtG0Y6vMl1mKSy/ClSj+VxkHNeZ6xIjFSKfwGi51so5hI+BNo7xwfYs4q58D9x2W
         B/sw==
X-Forwarded-Encrypted: i=1; AJvYcCWQ/JvFS5cwS4mXNGCnFikL7dgpLzWVNI6jKjB2LZrgpuALJcT+/+6xOL8s+ZKdJWRFwwflQc0Gg2o/MKMAvUh/wyjGJEkd/I44
X-Gm-Message-State: AOJu0YxcGs1CrRhf763nrgQ1fNVYp7upeDjMszqjvwF00tQuMvr34PBV
	8gV5wJHcZsrdSfuPIoc9IA/b1d3m6xPpKGSwkLSzr5cFyAm2ugcV
X-Google-Smtp-Source: AGHT+IEZ1OX3N9DDyixmV/0csvF1zpWYjHyudqQsgx6Rc2jOzZNMl0GVEne1FKKFl6Dzr+ARXQ+XoA==
X-Received: by 2002:ae9:e518:0:b0:788:663d:f38e with SMTP id w24-20020ae9e518000000b00788663df38emr18559933qkf.11.1710888560204;
        Tue, 19 Mar 2024 15:49:20 -0700 (PDT)
Received: from [10.193.190.170] (mobile-130-126-255-72.near.illinois.edu. [130.126.255.72])
        by smtp.gmail.com with ESMTPSA id g17-20020a05620a109100b00789e90a851asm4084589qkk.56.2024.03.19.15.49.19
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 19 Mar 2024 15:49:20 -0700 (PDT)
Message-ID: <5fde8ace-a0ac-4870-a7fe-ec2a24697112@gmail.com>
Date: Tue, 19 Mar 2024 17:49:19 -0500
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: horms@verge.net.au, ja@ssi.bg, davem@davemloft.net, dsahern@kernel.org,
 edumazet@google.com, kuba@kernel.org, pabeni@redhat.com
From: Zijie Zhao <zzjas98@gmail.com>
Subject: [net] Question about ipvs->sysctl_sync_threshold and READ_ONCE
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, chenyuan0y@gmail.com
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dear IPVS maintainers,

We encountered an unusual usage of sysctl parameter while analyzing 
kernel source code.


In include/net/ip_vs.h, line 1062 - 1070:

```
static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
{
	return ipvs->sysctl_sync_threshold[0];
}

static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
{
	return READ_ONCE(ipvs->sysctl_sync_threshold[1]);
}
```

Here, sysctl_sync_threshold[1] is accessed behind `READ_ONCE`, but 
sysctl_sync_threshold[0] is not. Should sysctl_sync_threshold[0] also be 
guarded by `READ_ONCE`?

Please kindly let us know if we missed any key information and this is 
actually intended. We appreciate your information and time! Thanks!


Links to the code:
https://elixir.bootlin.com/linux/v6.8.1/source/include/net/ip_vs.h#L1064
https://elixir.bootlin.com/linux/v6.8.1/source/include/net/ip_vs.h#L1069

Best,
Zijie
