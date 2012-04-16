From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Mon, 16 Apr 2012 20:31:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204162026480.6225@ja.ssi.bg>
References: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com> <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg> <201204161916.33621.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <201204161916.33621.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>


	Hello,

On Mon, 16 Apr 2012, Hans Schillstrom wrote:

> > 	But I see some inconsistency in net/core/net_namespace.c:
> > __register_pernet_operations when CONFIG_NET_NS is enabled
> > does not call ops_free after failed ops_init while when
> > CONFIG_NET_NS is not enabled ops_free is called. The 
> > problem is that we leak the ops->size data allocated for the
> > failed net. I think, the fix should be ops_init to free the data.
> 
> Are you sure ?
> In my code it does... 
> 
> static int __register_pernet_operations(struct list_head *list,
> 					struct pernet_operations *ops)
> at line 417
> ..
> 		for_each_net(net) {
> 			error = ops_init(ops, net);
> 			if (error)
> 				goto out_undo;

	There is line here that registers current net for
cleanup only after ops_init success:

	list_add_tail(&net->exit_list, &net_exit_list);

	If ops_init fails for first net then net_exit_list will
be empty.

> ...
> line 426
> out_undo:
> 	/* If I have an error cleanup all namespaces I initialized */
> 	list_del(&ops->list);
> 	ops_exit_list(ops, &net_exit_list);
> 	ops_free_list(ops, &net_exit_list);
> 	return error;
> }

Regards

--
Julian Anastasov <ja@ssi.bg>
