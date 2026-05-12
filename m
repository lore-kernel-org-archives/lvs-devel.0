Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com [209.85.208.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79BB41A6838
	for <lvs-devel@vger.kernel.org>; Tue, 12 May 2026 07:37:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.175
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778571431; cv=pass; b=DiBvrgM/8J3GNrh3wu8fI/I6+5xfshw/ZJYLQdQart8OoAmWmfDw3D6Fw6wTwOCdnlxj1IQbdEK4/0h5R8uUdHtGCwF9Jh5/nlO7TJDN1jTxR3gYoyWO84KZXRAN0Lp9K1Dj+NrvVBrCL4ESOSYLDnW8qWZ+M9nT29PeIYJyjos=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778571431; c=relaxed/simple;
	bh=bSuyYGGeEmgGvulV57SOqbxrkuecVl057GaOQUAOAak=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=M+4TQoeDSWQ6AUEPt95s5pMGoHyPmVkzGacspQVw2CiXyHBXrQhdi8jIf9B1FRYdj+i/1FboJOzAr2HuO7nu6uofveCiyoh/kejvq4q8Inrg6PMbnbyqrTzaMsNrBzyOsKvCyCJb4hmjjf+v1sO6nEUPZSrBQa/jdOZS7HZVLYk=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=AOLMsxdl; arc=pass smtp.client-ip=209.85.208.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="AOLMsxdl"
Received: by mail-lj1-f175.google.com with SMTP id 38308e7fff4ca-38e8292423fso35190481fa.0
        for <lvs-devel@vger.kernel.org>; Tue, 12 May 2026 00:37:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1778571427; cv=none;
        d=google.com; s=arc-20240605;
        b=Mqd5/t/ZLEnN6TvrB7I+vb0lVtQdHYDcCHVoFo8XHs1Po+VLvIhv37EQf4SF/fHBg5
         x+PZ5yClkbWQIJFDTSC9+sb+YOLj/Kp2vm2kG9BLszK1tEQDW2Rsp7MNzGzdgFegtdgo
         hvqsm2ix75F7Y2ukORhJO2b0S0DBieO/ENUbOTJvyc1FRjqW9IesiBmWIHB52uOtllzn
         TEt8hSw/MHxXqQxp4VQHII1etfq/cMMAe6UEDRn9VxMr6tPxKR67DNcB458nb2fM8522
         XmxkAdUMyU1bfXtitUqKF9OT8GfMveiUJYDv6ijKkPwWEy6cGKF+hUD5DvgNIu8r6Un5
         aRtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=YiGO1DzHy3oKJw39dEBo3ubhTMAjwaktPDTRNxo6tIs=;
        fh=XOXbcenIIdfvytyPZnxwtJ4C0QdNQO9+tJqyP5fys2Q=;
        b=dQMBn8us30+EVHaqwD0T/h55YINOyzgyfjbDWLKx/CVq/M4wSSQlbgm9VP8bLgwXbn
         7I01y58Bo/skUdGk0wUScS4jnrlFbwIYvJ+17rW84Eh8EwUkyOMDRAqkAeumEIdxSxn9
         X2tcKH3nO5zQrrlnhHXin3+lgASqQsV6k7D0hd0gKzly7KKZVdOLYnKdvBe3PV9OYlew
         FHsg/lXeJhCRtZ7KCIIT3bwdfHRMp0oIHW6ilNwY1DEJiC/S2A/jHV2PV3B90Q/AOUil
         g88M37q8Jw+083t0DgJZeM9AyvFLpX8TG6I9ZxSUAqhK7Mab61BEkcKZaRtmZHZFBkuU
         lK4g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1778571427; x=1779176227; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=YiGO1DzHy3oKJw39dEBo3ubhTMAjwaktPDTRNxo6tIs=;
        b=AOLMsxdl95RNOS40d/rtmgSLXWgPQOt8ahxDC98SXp7tJzs3Z0q33cublMzo5/5b0g
         yXX76g9PkD7gsk0pmOY7/nhW1JRZuZujU/Ov5Gg/YUQ3LpWGhv1JSjh7I8cHmfsrBaqN
         MKl30+aVCEVIfykxhfEYhqPRXrdWeMXx6gptCRU6c8Y0pjD3CcQFlwuNyBIbdi30udYR
         c/dKu8U2SLVAG2+TbuV70DpACrlVpAVoj4LU3id0oNhKWQLWIh9E3xjRCeSh+4k0ob+C
         zQalwA9xV3N6u9uRNP1T+SA9b6Sn7pergW3wonQ9up/alUvVjnm/4Tyx2jOFcNgPKyZw
         6w+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1778571427; x=1779176227;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=YiGO1DzHy3oKJw39dEBo3ubhTMAjwaktPDTRNxo6tIs=;
        b=op7TE5fyH8XRCngE8WxzVg7grWzoJiC6xt67O+dh8zMOqC9lxofkc77bMBezzo/73l
         pJ4Gvxjo6tzSo2I/GHgUpRjvMLF5Owor9S6v+vCUFxNHZE3GOeN+NFaadDwXLpdMoKDq
         hcsB4HsWN2b0/TxBV28FGEmwT61RY7QyE5D9+rhXBo4CIc6CB1wBBHX2VmMWNLdmRIUS
         NgYy8xlALGw8hWkD70S02CQLoARjroFHwKJ3rDvNNEG3ukVGctmLVXrY1wMsHSx/M+bO
         fSNckKyUK4gKLtOVJ9ar7YswuefgG/tg7uV5ynGHDzYo9fU3ocoOIuiB29ES1JC2RoyU
         Sl6Q==
X-Forwarded-Encrypted: i=1; AFNElJ9yluDtKZpqRU6QgHRbrYhOctdlMDmFjrlWkF9jpbIfynjHxRdiadTera2MAUQnJJXsPv8kbqDv+7g=@vger.kernel.org
X-Gm-Message-State: AOJu0YzWDPNelz6GxW0n1ufV9PZSlp8t8j9kl+JU3nz1ig5fsHWIhhJD
	qX6QOxojb1hxjzbMr8jH2539h0kBBMps0QzJgh/cz6N6Gtoldvj6XJ6rc3e220TSu556vXxs885
	ejN7ZfZj2faSnbZIbMR52JEzqGRWMKd3ricSkP7VENw==
X-Gm-Gg: Acq92OHl569jS22xNtsYikIhya2Rpu5TT0lwRI5WaOAC4F95noNKqwjHHJEZPmfbaQe
	tly75meUukfnSzOhWAaTILT3LLR2kl1Vh6typ7AusH1tTcyBXJlJ0p4O9btQsR8j6DQ+nGD+csi
	lT/lAhGLlK82ZaIdZescaBKQCo37yJAyb5+CcAUw7pOkrEutgFBUIQYXEwX6vXVmxVzrVuYF9w+
	70YShcZDNIU3NkgAhmKmSotGyu8xIZIvVZTrvJ23iKTS06v+kqk1KDDNJOEqBfnpjHJk35BRspX
	DkqPeFsCNoXosCMijTAqfVmhdR8KNkRQnFOSwelb
X-Received: by 2002:ac2:4f03:0:b0:5a3:cc81:eff3 with SMTP id
 2adb3069b0e04-5a8e31e792cmr603618e87.26.1778571427561; Tue, 12 May 2026
 00:37:07 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260511134744.277032-1-marco.crivellari@suse.com>
 <20260511134744.277032-3-marco.crivellari@suse.com> <734b9aa0-3af4-819a-49fe-8bba7035856f@ssi.bg>
In-Reply-To: <734b9aa0-3af4-819a-49fe-8bba7035856f@ssi.bg>
From: Marco Crivellari <marco.crivellari@suse.com>
Date: Tue, 12 May 2026 09:36:56 +0200
X-Gm-Features: AVHnY4Lehk_93YiMVYGd670SPnAUadqGsUhTvlPZSmybCIwdKkGr50QbaYqby5c
Message-ID: <CAAofZF43Yee8ZutA0mR=PnsinkbHwFEafQqtVPvcACpVNhtu=Q@mail.gmail.com>
Subject: Re: [PATCH net-next 2/2] ipvs: Replace use of system_unbound_wq with system_dfl_wq
To: Julian Anastasov <ja@ssi.bg>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
	Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, 
	Frederic Weisbecker <frederic@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, 
	Michal Hocko <mhocko@suse.com>, Simon Horman <horms@verge.net.au>, Eric Dumazet <edumazet@google.com>, 
	"David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>, 
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, May 12, 2026 at 6:22=E2=80=AFAM Julian Anastasov <ja@ssi.bg> wrote:
> [...]
>         Sorry that such change was delayed but there were
> many changes in IPVS for the last month. The last that may
> delay this patch is:
>
> v3 of "ipvs: avoid possible loop in ip_vs_dst_event on resizing"
> https://lore.kernel.org/lvs-devel/20260510104605.24218-1-ja@ssi.bg/T/#u
>
>         May be we have to wait this change to reach net and
> net-next. Also, we can reconsider which queue to use, these works
> resize hash tables and call synchronize_rcu(), should we switch to
> system_dfl_long_wq if such job is considered "long" ?

Hello Julian,

Thanks for letting me know.

Yes, if it is considered long we can switch to the long unbound version.
I will prepare the v2 with this change.

Thanks!

--

Marco Crivellari

SUSE Labs
