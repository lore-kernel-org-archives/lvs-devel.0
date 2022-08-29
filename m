From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net-next] genetlink: start to validate reserved header
 bytes
Date: Mon, 29 Aug 2022 12:32:54 -0400
Message-ID: <YwzqNgj/bJoawrwh@zx2c4.com>
References: <20220825001830.1911524-1-kuba@kernel.org>
Mime-Version: 1.0
Return-path: <linux-scsi-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105;
        t=1661790778;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=3F5bs6wEmRDmdIQe96V5iwCeWjK5YoVTeKEuPdxSfN4=;
        b=kNQTi4K8egLdu1zNarBL47SQOYWe4WMkhvHrAwskcAG/1adfCVQBMB0gvduSpWFDbav2Tj
        2LIfVOx4v++zHCwTjVPKSR+kizVUx5w5Af4coUKZm2ZWFtmVrqoa79XBz+/8OYj2RpZKfG
        GTXOi7IPk9NkM/oVEZTI4HyRLLvuSmE=
Content-Disposition: inline
In-Reply-To: <20220825001830.1911524-1-kuba@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <kuba@kernel.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com, pabeni@redhat.com, jiri@resnulli.us, johannes@sipsolutions.net, linux-block@vger.kernel.org, osmocom-net-gprs@lists.osmocom.org, linux-wpan@vger.kernel.org, wireguard@lists.zx2c4.com, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-pm@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-cifs@vger.kernel.org, cluster-devel@redhat.com, mptcp@lists.linux.dev, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-security-module@vger.kernel.org, dev@openvswitch.org, linux-s390@vger.kernel.org, tipc-discussion@lists.sourceforge.net

Hi Jakub,

On Wed, Aug 24, 2022 at 05:18:30PM -0700, Jakub Kicinski wrote:
> diff --git a/drivers/net/wireguard/netlink.c b/drivers/net/wireguard/netlink.c
> index d0f3b6d7f408..0c0644e762e5 100644
> --- a/drivers/net/wireguard/netlink.c
> +++ b/drivers/net/wireguard/netlink.c
> @@ -621,6 +621,7 @@ static const struct genl_ops genl_ops[] = {
>  static struct genl_family genl_family __ro_after_init = {
>  	.ops = genl_ops,
>  	.n_ops = ARRAY_SIZE(genl_ops),
> +	.resv_start_op = WG_CMD_SET_DEVICE + 1,
>  	.name = WG_GENL_NAME,
>  	.version = WG_GENL_VERSION,
>  	.maxattr = WGDEVICE_A_MAX,

FWIW, I wouldn't object to just leaving this at zero. I don't know of
any wireguard userspaces doing anything with the reserved header field.

Jason
