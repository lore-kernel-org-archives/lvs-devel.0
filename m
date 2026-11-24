Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=13.75.44.102
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795524498;
	b=LZnmwe3mTD6pq9xlrHAoiIy5ndkbxPzK89dVr1N5Z94bX2FLqwwdQFOPo0/yM0ZkCQAd
	 gBjyGSFJQ0ozc9tmgFR4Gg+mEWCuZ85ee/MFO9rNK+0VEYfh3jKHVmFIaPcuKgL/TB9i1
	 mdu8wH8Kz2YifO4TOYUQEspBpooYPcsa/FsHN+TfYgEFOJiMjaONiZ/XsmUhh3S0xfEXB
	 eL8TgXsaRml1glrdT5KtmEWYtvZKsG2xZVn0Arz58gs9e8KM56jK8UmzQE08pi9e3qgjV
	 xDf6VdWnZVozQ+kuut5EnMVePFze4QlTGIQ19iBNUL979CDoiLLIgIKkMhEZSgMf9Qw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795524498;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-CM-TRANSID:X-Coremail-Antispam:X-CM-SenderInfo;
	bh=/PWd18l0eDqXOlcuoD9UjIb4JghxABihIehp2sykkVE=;
	b=LxjTU9V+TRWK30wirVLSHnee5miwILpmfVt2PPUqDdkQfRNyu2GJrWLa1YlD3D9Hyht0
	 64W4QQin+6UwpRMzx5jcUGGKN6QGlPeKGV79JSg+DIwZpgOk39rcCgTQ1YzI+DsYeK9Ah
	 MkGSluDfdRc3YRIAceKdO3lPkMcF8FpbR6tQ2DJVWTfxS+HAewxB8lWvEqC6gJSkE6nY0
	 t5F/oElUtF9Dk613V2uMycDcS6F/vt3Ltf3cPx5b5RfV4lV98X3ScWhKCTFLURprYRLoi
	 OVR1gdto+0rbLrjEUxy6onAwEnXDyIPN8wmxgDV2xIBOg+rvlZgEGN8HM2CrMjOuw2Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=stu.xjtu.edu.cn;
	spf=pass smtp.mailfrom=stu.xjtu.edu.cn;
	arc=none smtp.remote-ip=13.75.44.102
Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.75.44.102])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2DB22606A32C;
	Tue, 24 Nov 2026 12:48:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2DB22606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stu.xjtu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stu.xjtu.edu.cn
Received: from fxxowodeMacBook-Pro.local (unknown [10.181.177.214])
	by app2 (Coremail) with SMTP id NAGowADHd5SChwVrDrZ9AA--.16351S2;
	Tue, 24 Nov 2026 20:48:04 +0800 (CST)
Date: Tue, 24 Nov 2026 07:47:56 -0500
From: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Xing Feng <xingfeng@stu.xjtu.edu.cn>,
	Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: Re: [BUG] ipvs: new connection on a reused port goes to the previous
 real server during conn_tab resize
Message-ID: <awWHfO0EgdLoOxLi@fxxowodeMacBook-Pro.local>
References: <avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local>
 <d876f5ef-982a-0ddb-5e75-3434453c2ccf@ssi.bg>
 <av7f6F123V2WDd_u@fxxowodeMacBook-Pro.local>
 <a5aa2a54-d8ea-bbe1-3a72-d672d6fd92c4@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5aa2a54-d8ea-bbe1-3a72-d672d6fd92c4@ssi.bg>
X-CM-TRANSID:NAGowADHd5SChwVrDrZ9AA--.16351S2
X-Coremail-Antispam: 1UD129KBjvJXoW7tFyUArWDtr1xtFWxWr4xXrb_yoW8ArW8pF
	WqkryYyw47JFyfWwsYkw4UCr18AFs3Xw15Xrn0ga42g390grnavFWFga4DJayUZrZ3ur1j
	vFWYqwsIv3Z8AaUanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvl1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l1IIY67AE
	w4v_Jr0_Jr4l8cAvFVAK0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2
	IY67AKxVW5JVW7JwA2z4x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwA2z4x0Y4vEx4A2
	jsIE14v26rxl6s0DM28EF7xvwVC2z280aVCY1x0267AKxVW0oVCq3wAS0I0E0xvYzxvE52
	x082IY62kv0487Mc02F40EFcxC0VAKzVAqx4xG6I80ewAv7VC0I7IYx2IY67AKxVWUJVWU
	GwAv7VC2z280aVAFwI0_Jr0_Gr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcVAKI48JM4
	x0x7Aq67IIx4CEVc8vx2IErcIFxwCY1x0262kKe7AKxVWUAVWUtwCY02Avz4vE-syl42xK
	82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8Cr1UJr1l4I8I3I0E4IkC6x0Yz7v_Jr
	0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY
	17CE14v26r126r1DMIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcV
	C0I7IYx2IY6xkF7I0E14v26r1j6r4UMIIF0xvE42xK8VAvwI8IcIk0rVWUJVWUCwCI42IY
	6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r1j6r4UYxBIdaVFxhVjvj
	DU0xZFpf9x0JUBVbkUUUUU=
X-CM-SenderInfo: 5hqgt5hwuh2iqrsqq2dwxo5ylwxovvfxof0/

Hello Julian,

On Fri, Nov 20, 2026 at 06:55:07AM +0200, Julian Anastasov wrote:
> 	Appending a RFC version for testing. It is for the net
> tree because it contains all recent fixes for IPVS.
> 
> [PATCH RFC net] ipvs: fix connection reuse with the resizable hash tables


Thanks for the patch. We tested it on the net tree (af6737b90,
7.4.0-rc3) in a KVM guest with 8 vCPUs, using the reproducer from the
report:

  mode      kernel    reused-port   misrouted     answered     failed
                      connections   connections   > 100 ms
  force     net         13289          413          333        35 reset
  force     net+RFC     15634            0            0             0
  grow      net         15584            7            5         1 reset
  grow      net+RFC     15678            0            0             0
  noresize  net          7841            0            0             0
  noresize  net+RFC      7834            0            0             0

(force: 60 s, conn_lfactor written every 100 ms; grow: 60 s, all
defaults; noresize: 30 s, conn_lfactor=8.)

With the patch no packet of a reused-port connection went to another
real server than its SYN, and the client saw no delayed or failed
exchanges.

To check for regressions we also ran, on both kernels:

- tools/testing/selftests/net/netfilter/ipvs.sh: PASS on both.
- Rolling updates with drained and deleted real servers, and reused
  ports with conn_reuse_mode=0, in a NAT setup with kube-proxy's
  sysctls: same results on both kernels.
- Master/backup sync with reused-port traffic and forced resizes: the
  backup's entries for the reused ports matched the master's on 20 of
  20 ports with the patch, 22 of 30 without.
- Persistent service (-p 60) with reused ports and forced resizes:
  every connection reached the same real server, on both kernels.

We did not construct the case of a late packet from the old real
server (e.g. a retransmitted FIN) after its connection was marked
reused.

Tested-by: Zhenrong (Daniel) Gu <zrgu@stu.xjtu.edu.cn>

Thanks,
Zhenrong Gu

