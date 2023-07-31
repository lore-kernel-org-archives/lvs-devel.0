From: Simon Horman <horms-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 03/14] sysctl: Add ctl_table_size to ctl_table_header
Date: Mon, 31 Jul 2023 20:30:21 +0200
Message-ID: <ZMf9vZpGE98oM9W2@kernel.org>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <20230731071728.3493794-4-j.granados@samsung.com>
Mime-Version: 1.0
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1690828234;
        bh=azdNP8cF85m7UDvgXMTAEEGyM/wWyMIGFgmuwIc8ul0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=O1VpJucJ8qJ4G6AE1OKV3xdN/xK/FDklzv/nwqYZajcZtRy+LSUQU50X+sHs9AxvB
         xsU2buC2SUK4CZR3jjYJZtrydR9Bbqd9WCPwdG5zMYEjJLfGD0nXQIDtdar/ei7qKh
         Q4AFqyXfVyBH57dywLI4uw0Frcitouu9e42wpiwCGypovk04FOzCfl60zxzFG2eyak
         ANZHJkor5YlN+5saTB/xwrXYhgw16Q93h89m9IIkWKyhNAHwsbqX1ZrfONEa6iuY6k
         btG9dsvLFpB0/w7f/xaTE6xEYGtgYWH7rF7vGs2JSC6YVtwrN6iixwxcTNdpmmdRV2
         wiQHQ/+OXxCxw==
Content-Disposition: inline
In-Reply-To: <20230731071728.3493794-4-j.granados-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joel Granados <joel.granados-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Iurii Zaikin <yzaikin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Sven Schnelle <svens-tEXmvtCZX7AybS5Ee8rs3A@public.gmane.org>, Marcelo Ricardo Leitner <marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, "D. Wythe" <alibuda-KPsoFbNs7GizrGE5bRqYAgC/G2K4zDHf@public.gmane.org>, mptcp-cunTk1MwBs/YUNznpcFYbw@public.gmane.org, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Vasily Gorbik <gor-tEXmvtCZX7AybS5Ee8rs3A@public.gmane.org>, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jan Karcher <jaka-tEXmvtCZX7AybS5Ee8rs3A@public.gmane.org>, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Will Deacon <will-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>, Matthieu Baerts <matthieu.baerts-g9H5/arvmg7k1uMJSBkQmQ@public.gmane.org>, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-arm-kernel-IAPFreCvJWNGWvitb5QawA@public.gmane.org

On Mon, Jul 31, 2023 at 09:17:17AM +0200, Joel Granados wrote:
> The new ctl_table_size element will hold the size of the ctl_table
> arrays contained in the ctl_table_header. This value should eventually
> be passed by the callers to the sysctl register infrastructure. And
> while this commit introduces the variable, it does not set nor use it
> because that requires case by case considerations for each caller.
> 
> It provides two important things: (1) A place to put the
> result of the ctl_table array calculation when it gets introduced for
> each caller. And (2) the size that will be used as the additional
> stopping criteria in the list_for_each_table_entry macro (to be added
> when all the callers are migrated)
> 
> Signed-off-by: Joel Granados <j.granados-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> ---
>  include/linux/sysctl.h | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 59d451f455bf..33252ad58ebe 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -159,12 +159,22 @@ struct ctl_node {
>  	struct ctl_table_header *header;
>  };
>  
> -/* struct ctl_table_header is used to maintain dynamic lists of
> -   struct ctl_table trees. */
> +/**
> + * struct ctl_table_header - maintains dynamic lists of struct ctl_table trees
> + * @ctl_table: pointer to the first element in ctl_table array
> + * @ctl_table_size: number of elements pointed by @ctl_table
> + * @used: The entry will never be touched when equal to 0.
> + * @count: Upped every time something is added to @inodes and downed every time
> + *         something is removed from inodes
> + * @nreg: When nreg drops to 0 the ctl_table_header will be unregistered.
> + * @rcu: Delays the freeing of the inode. Introduced with "unfuck proc_sysctl ->d_compare()"
> + *
> + */

Hi Joel,

Please consider also adding kernel doc entries for the other fields of
struct ctl_table_header. According to ./scripts/kernel-doc -none
they are:

  unregistering
  ctl_table_arg
  root
  set
  parent
  node
  inodes


>  struct ctl_table_header {
>  	union {
>  		struct {
>  			struct ctl_table *ctl_table;
> +			int ctl_table_size;
>  			int used;
>  			int count;
>  			int nreg;
> -- 
> 2.30.2
> 
