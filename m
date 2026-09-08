Received: from mail-m49198.qiye.163.com (mail-m49198.qiye.163.com [45.254.49.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29B0D5328A6;
	Tue,  8 Sep 2026 15:49:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.254.49.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788882586; cv=none; b=lO78DSwY24/UMRS5gK6yzmQnhhE/cpERBN7bw6dVvqxKNdjfA3FvUxhQ/1Ri5yb0xFKu8wrP9MWfq8jG1eVTFtYhVfSEUyGanIHREQECuK63Er360NRejtwZHPLhqBrllfqVg1FODkVyQlqcDB8VRt2E+uSelvWtuzjcjNHe0pc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788882586; c=relaxed/simple;
	bh=8B0coZUb+uVJNUpVOXi74qHy8mGVAfGtWD8DWznvRsQ=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version:Content-Type; b=kWqfNGSJVMI1UwWPB4qo67C5MPSwJ7UgQaT7+pnXfq6cXqpF5oCLE7UABwCarzO2tL+r5el+rV66RpY/8CAhSEzlAvkQfZBrge+4jPmO+CZ+iN9gZh72wf+dE2LWN7X/L3j7dBsP5cXDcYANyFYcHVbqnl5EKTQI14gfIfN4cKY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn; spf=pass smtp.mailfrom=seu.edu.cn; dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b=JmSngCFq; arc=none smtp.client-ip=45.254.49.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b="JmSngCFq"
Received: from PC-202605011814.localdomain (unknown [222.191.246.242])
	by smtp.qiye.163.com (Hmail) with ESMTP id 4cfeed839;
	Tue, 8 Sep 2026 23:49:30 +0800 (GMT+08:00)
From: Runyu Xiao <runyu.xiao@seu.edu.cn>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Jianhao Xu <jianhao.xu@seu.edu.cn>
Subject: Re: [PATCH net] ipvs: shut down destination trash timer on netns cleanup
Date: Tue,  8 Sep 2026 23:48:56 +0800
Message-Id: <20260908154856.677532-1-runyu.xiao@seu.edu.cn>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <98268ae8-1007-78c7-8124-2d37454d8b46@ssi.bg>
References: <20260904071908.4052966-1-runyu.xiao@seu.edu.cn> <98268ae8-1007-78c7-8124-2d37454d8b46@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-HM-Tid: 0aa081b5cb5a03a1kunm058f935b124beb
X-HM-MType: 10
X-HM-Spam-Status: e1kfGhgUHx5ZQUpXWQgPGg8OCBgUHx5ZQUlOS1dZFg8aDwILHllBWSg2Ly
	tZV1koWUFITzdXWRgWCB1ZQUpXWS1ZQUlXWQ8JGhUIEh9ZQVkaGktNVhodQ0gaSRpNTRhCTlYeHw
	5VEwETFhoSFyQUDg9ZV1kYEgtZQVlJSUlVSkJKVUlPTVVJT0lZV1kWGg8SFR0UWUFZT0tIVUJCSU
	5LVUpLS1VKQktCWQY+
DKIM-Signature: a=rsa-sha256;
	b=JmSngCFq14WVyQFPp9HKpHaVguoUI81TN94g+0IhKS9K20yjSuQCoH25EbcauBbr7ELr933uLE0z7QhWh0PSCABRkfZ6sdUAM6gq+0+g2CptD0UI8HkIrqmoTJkL1h/GdlqOxflHkEy8u/KEdy9WPNYqinJloJVKIlErbRWR28I=; c=relaxed/relaxed; s=default; d=seu.edu.cn; v=1;
	bh=8B0coZUb+uVJNUpVOXi74qHy8mGVAfGtWD8DWznvRsQ=;
	h=date:mime-version:subject:message-id:from;

Hi Julian,

Thanks for reviewing this.

On Fri, 4 Sep 2026, Julian Anastasov wrote:
> timer_delete_sync() can safely stop timer if it
> is rearmed by its callback: __timer_delete_sync() waits
> the callback to finish (the callback can rearm it) and
> then detach it if pending. There must be another call flow
> that can rearm it later, otherwise this patch is not needed.
>
> During cleanup, we do not start the timer from
> ip_vs_trash_put_dest(). May be I'm missing something?

You are right. I missed that the netns cleanup path passes cleanup=true
through ip_vs_flush() and __ip_vs_del_dest() to ip_vs_trash_put_dest().
The !cleanup guard therefore prevents that path from rearming
dest_trash_timer. If the timer callback is already running,
timer_delete_sync() waits for it to finish and removes any timer that the
callback rearmed before returning.

There is therefore no reachable post-cleanup rearm in this path, and the
proposed timer_shutdown_sync() change is unnecessary. Please consider the
v1 patch withdrawn; I will not send a v2.

Sorry for the noise, and thanks for pointing this out.

Regards,
Runyu
