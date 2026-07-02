Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 736182F39B5
	for <lvs-devel@vger.kernel.org>; Thu,  2 Jul 2026 10:31:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782988310; cv=none; b=t8gO2kPPZdgt423iEdikPLX7icw+uGNuXKW1iEYPgPnNDgHdT5CA25UvKfupaakYwojk5zdZPQJgKVKOYZfPGCafjdQZpVZ80y+m8KmVZXyQd/RNqEdxLTflsZneDHjWD8qCepu3BjoAJM9qzkQqtb9hZHEsqIsvExbqi7KNkAs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782988310; c=relaxed/simple;
	bh=ZIn43INLbi+LDQ+Jho+E7TvyEDjesltuVNzl70tMzXI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qFYbV/PF0DNlrFS2To4xPKRmj05wb/TVfWZwNpxhozhw3a/pnAzjfRxMe50LHNc1gnHRm51kTX3JZ3mgbi8QVxqEfCJY+MWf70UmkNHhkN0sxdiZ/SSUswHUIGOpQSUGWIfHvbZwNHioprsgSPyc55kV5A6e82wAcyT3jmHaB2U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=ex0LboEa; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=QUm/UZC1; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=0nNK6jVq; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=1OWps0PR; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="ex0LboEa";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="QUm/UZC1";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="0nNK6jVq";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="1OWps0PR"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id CBF177413D;
	Thu,  2 Jul 2026 10:31:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1782988308; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZIn43INLbi+LDQ+Jho+E7TvyEDjesltuVNzl70tMzXI=;
	b=ex0LboEa8fFnAEv0LlWTtFnatYcXb12UGzPYE8RM0RFub6EzMyi6RGWN+ASBSLwsWmyem8
	egJmmxESX74VD8hiknkNpZyUAffVxWUet7CSy0KgWaRlT0hjOrJLEGC7EyDJFXaD1bNV0r
	JZMVQN6xdDtNviD5y7ePhJfiB88aSfs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1782988308;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZIn43INLbi+LDQ+Jho+E7TvyEDjesltuVNzl70tMzXI=;
	b=QUm/UZC149yJeiIYvETGPmY5UYxOQ7xdQ0/WK9YuFlBFkl3o1gCN7rtgSUkKkTgE88n5pL
	laDIwAqAMucp8eBQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1782988306; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZIn43INLbi+LDQ+Jho+E7TvyEDjesltuVNzl70tMzXI=;
	b=0nNK6jVqThlA/eO3avNstwKg3CyN0nK4aiqiwwF3lvpEtddK/2LGQtA7xmqzqIn2pkYwFD
	lmfrP38MRPWTmS6iXcfq7sbUaEDhnxoMBAdsEicEH0FT8ZB+dBWPNhSqHoDNoPrENCailp
	w5ki8zFLX5w0Iv5Ay8oQ5SqrUS6Qbv0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1782988306;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZIn43INLbi+LDQ+Jho+E7TvyEDjesltuVNzl70tMzXI=;
	b=1OWps0PRdWwT2QFYrjMkvaR4O0jAX/EnbjSyJmqeU0fTSMPKYIuxrdagVsjcEJqfjdxEU9
	OcQl+H2T/CU3W7CQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A2C6E779AA;
	Thu,  2 Jul 2026 10:31:46 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id Xj3KJBI+RmqXPAAAD6G6ig
	(envelope-from <iluceno@suse.de>); Thu, 02 Jul 2026 10:31:46 +0000
Date: Thu, 2 Jul 2026 12:31:45 +0200
From: Ismael Luceno <iluceno@suse.de>
To: linux-kernel@vger.kernel.org
Cc: "open list:IPVS" <netdev@vger.kernel.org>,
	"open list:IPVS" <lvs-devel@vger.kernel.org>,
	"open list:NETFILTER" <netfilter-devel@vger.kernel.org>,
	"open list:NETFILTER" <coreteam@netfilter.org>
Subject: Re: [PATCH v2 nf-next] ipvs: Move defense_work and est_reload_work
 to system_dfl_long_wq
Message-ID: <akY-CMqFSLVgK8hG@pirotess>
References: <20260702101100.24256-2-iluceno@suse.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260702101100.24256-2-iluceno@suse.de>
X-Spam-Flag: NO
X-Spamd-Result: default: False [-2.76 / 50.00];
	BAYES_HAM(-3.00)[99.98%];
	HFILTER_URL_ONLY(1.03)[0.46666666666667];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.19)[-0.945];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	MIME_TRACE(0.00)[0:+];
	MISSING_XM_UA(0.00)[];
	TO_DN_SOME(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCPT_COUNT_FIVE(0.00)[5];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo]
X-Spam-Level: 
X-Spam-Score: -2.76

Link: https://lore.kernel.org/all/20260317140100.24993-2-iluceno@suse.de/
