From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 2/3] ipvs: replace the SCTP state machine
Date: Wed, 19 Jun 2013 09:52:57 +0900
Message-ID: <20130619005256.GA19345@verge.net.au>
References: <1371539288-5036-1-git-send-email-ja@ssi.bg>
 <1371539288-5036-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371539288-5036-3-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Tue, Jun 18, 2013 at 10:08:07AM +0300, Julian Anastasov wrote:
> Convert the SCTP state table, so that it is more readable.
> Change the states to be according to the diagram in RFC 2960
> and add more states suitable for middle box. Still, such
> change in states adds incompatibility if systems in sync
> setup include this change and others do not include it.
>=20
> With this change we also have proper transitions in INPUT-ONLY
> mode (DR/TUN) where we see packets only from client. Now
> we should not switch to 10-second CLOSED state at a time
> when we should stay in ESTABLISHED state.
>=20
> The short names for states are because we have 16-char space
> in ipvsadm and 11-char limit for the connection list format.
> It is a sequence of the TCP implementation where the longest
> state name is ESTABLISHED.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Hi Julian,

I am having trouble applying the first ip_vs_proto_sctp.c hunk.

I have tried against net-next, nf-next and ipvs-next.
Could you rebase it on the later and repost it with the second patch of
this series?

I will take the first patch and see about getting it included in v3.10.

> ---
>  include/net/ip_vs.h                   |   21 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  854 ++++++-----------------=
----------
>  net/netfilter/ipvs/ip_vs_sync.c       |    7 +-
>  3 files changed, 168 insertions(+), 714 deletions(-)
>=20
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 95860df..e667df1 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -380,17 +380,18 @@ enum {
>   */
>  enum ip_vs_sctp_states {
>  	IP_VS_SCTP_S_NONE,
> -	IP_VS_SCTP_S_INIT_CLI,
> -	IP_VS_SCTP_S_INIT_SER,
> -	IP_VS_SCTP_S_INIT_ACK_CLI,
> -	IP_VS_SCTP_S_INIT_ACK_SER,
> -	IP_VS_SCTP_S_ECHO_CLI,
> -	IP_VS_SCTP_S_ECHO_SER,
> +	IP_VS_SCTP_S_INIT1,
> +	IP_VS_SCTP_S_INIT,
> +	IP_VS_SCTP_S_COOKIE_SENT,
> +	IP_VS_SCTP_S_COOKIE_REPLIED,
> +	IP_VS_SCTP_S_COOKIE_WAIT,
> +	IP_VS_SCTP_S_COOKIE,
> +	IP_VS_SCTP_S_COOKIE_ECHOED,
>  	IP_VS_SCTP_S_ESTABLISHED,
> -	IP_VS_SCTP_S_SHUT_CLI,
> -	IP_VS_SCTP_S_SHUT_SER,
> -	IP_VS_SCTP_S_SHUT_ACK_CLI,
> -	IP_VS_SCTP_S_SHUT_ACK_SER,
> +	IP_VS_SCTP_S_SHUTDOWN_SENT,
> +	IP_VS_SCTP_S_SHUTDOWN_RECEIVED,
> +	IP_VS_SCTP_S_SHUTDOWN_ACK_SENT,
> +	IP_VS_SCTP_S_REJECTED,
>  	IP_VS_SCTP_S_CLOSED,
>  	IP_VS_SCTP_S_LAST
>  };
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ip=
vs/ip_vs_proto_sctp.c
> index df29d64..3c0da87 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -185,710 +185,159 @@ sctp_csum_check(int af, struct sk_buff *skb, =
struct ip_vs_protocol *pp)
>  	return 1;
>  }
> =20
> -struct ipvs_sctp_nextstate {
> -	int next_state;
> -};
>  enum ipvs_sctp_event_t {
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_DATA_SER,
> -	IP_VS_SCTP_EVE_INIT_CLI,
> -	IP_VS_SCTP_EVE_INIT_SER,
> -	IP_VS_SCTP_EVE_INIT_ACK_CLI,
> -	IP_VS_SCTP_EVE_INIT_ACK_SER,
> -	IP_VS_SCTP_EVE_COOKIE_ECHO_CLI,
> -	IP_VS_SCTP_EVE_COOKIE_ECHO_SER,
> -	IP_VS_SCTP_EVE_COOKIE_ACK_CLI,
> -	IP_VS_SCTP_EVE_COOKIE_ACK_SER,
> -	IP_VS_SCTP_EVE_ABORT_CLI,
> -	IP_VS_SCTP_EVE__ABORT_SER,
> -	IP_VS_SCTP_EVE_SHUT_CLI,
> -	IP_VS_SCTP_EVE_SHUT_SER,
> -	IP_VS_SCTP_EVE_SHUT_ACK_CLI,
> -	IP_VS_SCTP_EVE_SHUT_ACK_SER,
> -	IP_VS_SCTP_EVE_SHUT_COM_CLI,
> -	IP_VS_SCTP_EVE_SHUT_COM_SER,
> -	IP_VS_SCTP_EVE_LAST
> +	IP_VS_SCTP_DATA =3D 0,		/* DATA, SACK, HEARTBEATs */
> +	IP_VS_SCTP_INIT,
> +	IP_VS_SCTP_INIT_ACK,
> +	IP_VS_SCTP_COOKIE_ECHO,
> +	IP_VS_SCTP_COOKIE_ACK,
> +	IP_VS_SCTP_SHUTDOWN,
> +	IP_VS_SCTP_SHUTDOWN_ACK,
> +	IP_VS_SCTP_SHUTDOWN_COMPLETE,
> +	IP_VS_SCTP_ERROR,
> +	IP_VS_SCTP_ABORT,
> +	IP_VS_SCTP_EVENT_LAST
>  };
> =20
> -static enum ipvs_sctp_event_t sctp_events[256] =3D {
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_INIT_CLI,
> -	IP_VS_SCTP_EVE_INIT_ACK_CLI,
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_ABORT_CLI,
> -	IP_VS_SCTP_EVE_SHUT_CLI,
> -	IP_VS_SCTP_EVE_SHUT_ACK_CLI,
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_COOKIE_ECHO_CLI,
> -	IP_VS_SCTP_EVE_COOKIE_ACK_CLI,
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_DATA_CLI,
> -	IP_VS_SCTP_EVE_SHUT_COM_CLI,
> +/* RFC 2960, 3.2 Chunk Field Descriptions */
> +static __u8 sctp_events[] =3D {
> +	[SCTP_CID_DATA]			=3D IP_VS_SCTP_DATA,
> +	[SCTP_CID_INIT]			=3D IP_VS_SCTP_INIT,
> +	[SCTP_CID_INIT_ACK]		=3D IP_VS_SCTP_INIT_ACK,
> +	[SCTP_CID_SACK]			=3D IP_VS_SCTP_DATA,
> +	[SCTP_CID_HEARTBEAT]		=3D IP_VS_SCTP_DATA,
> +	[SCTP_CID_HEARTBEAT_ACK]	=3D IP_VS_SCTP_DATA,
> +	[SCTP_CID_ABORT]		=3D IP_VS_SCTP_ABORT,
> +	[SCTP_CID_SHUTDOWN]		=3D IP_VS_SCTP_SHUTDOWN,
> +	[SCTP_CID_SHUTDOWN_ACK]		=3D IP_VS_SCTP_SHUTDOWN_ACK,
> +	[SCTP_CID_ERROR]		=3D IP_VS_SCTP_ERROR,
> +	[SCTP_CID_COOKIE_ECHO]		=3D IP_VS_SCTP_COOKIE_ECHO,
> +	[SCTP_CID_COOKIE_ACK]		=3D IP_VS_SCTP_COOKIE_ACK,
> +	[SCTP_CID_ECN_ECNE]		=3D IP_VS_SCTP_DATA,
> +	[SCTP_CID_ECN_CWR]		=3D IP_VS_SCTP_DATA,
> +	[SCTP_CID_SHUTDOWN_COMPLETE]	=3D IP_VS_SCTP_SHUTDOWN_COMPLETE,
>  };
> =20
> -static struct ipvs_sctp_nextstate
> - sctp_states_table[IP_VS_SCTP_S_LAST][IP_VS_SCTP_EVE_LAST] =3D {
> -	/*
> -	 * STATE : IP_VS_SCTP_S_NONE
> -	 */
> -	/*next state *//*event */
> -	{{IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ },
> -	 },
> -	/*
> -	 * STATE : IP_VS_SCTP_S_INIT_CLI
> -	 * Cient sent INIT and is waiting for reply from server(In ECHO_WAI=
T)
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_ECHO_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_INIT_SER
> -	 * Server sent INIT and waiting for INIT ACK from the client
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_INIT_ACK_CLI
> -	 * Client sent INIT ACK and waiting for ECHO from the server
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK has been resent by the client, let us stay is in
> -	  * the same state
> -	  */
> -	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 /*
> -	  * INIT_ACK sent by the server, close the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * ECHO by client, it should not happen, close the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 /*
> -	  * ECHO by server, this is what we are expecting, move to ECHO_SER
> -	  */
> -	 {IP_VS_SCTP_S_ECHO_SER /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, it should not happen, close the connect=
ion
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 /*
> -	  * Unexpected COOKIE ACK from server, staty in the same state
> -	  */
> -	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_INIT_ACK_SER
> -	 * Server sent INIT ACK and waiting for ECHO from the client
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * Unexpected INIT_ACK by the client, let us close the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 /*
> -	  * INIT_ACK resent by the server, let us move to same state
> -	  */
> -	 {IP_VS_SCTP_S_INIT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client send the ECHO, this is what we are expecting,
> -	  * move to ECHO_CLI
> -	  */
> -	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 /*
> -	  * ECHO received from the server, Not sure what to do,
> -	  * let us close it
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, let us stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_INIT_ACK_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 /*
> -	  * COOKIE ACK from server, hmm... this should not happen, lets clo=
se
> -	  * the connection.
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_ECHO_CLI
> -	 * Cient  sent ECHO and waiting COOKEI ACK from the Server
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK has been by the client, let us close the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client resent the ECHO, let us stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 /*
> -	  * ECHO received from the server, Not sure what to do,
> -	  * let us close it
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, this shoud not happen, let's close the
> -	  * connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 /*
> -	  * COOKIE ACK from server, this is what we are awaiting,lets move =
to
> -	  * ESTABLISHED.
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_ECHO_SER
> -	 * Server sent ECHO and waiting COOKEI ACK from the client
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ECHO_SER /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 /*
> -	  * INIT_ACK has been by the server, let us close the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client sent the ECHO, not sure what to do, let's close the
> -	  * connection.
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 /*
> -	  * ECHO resent by the server, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ECHO_SER /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, this is what we are expecting, let's mo=
ve
> -	  * to ESTABLISHED.
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 /*
> -	  * COOKIE ACK from server, this should not happen, lets close the
> -	  * connection.
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_ESTABLISHED
> -	 * Association established
> -	 */
> -	{{IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> -	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> -	  * it will send ERROR chunk. So, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 /*
> -	  * SHUTDOWN from the client, move to SHUDDOWN_CLI
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 /*
> -	  * SHUTDOWN from the server, move to SHUTDOWN_SER
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 /*
> -	  * client sent SHUDTDOWN_ACK, this should not happen, let's close
> -	  * the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_SHUT_CLI
> -	 * SHUTDOWN sent from the client, waitinf for SHUT ACK from the ser=
ver
> -	 */
> -	/*
> -	 * We received the data chuck, keep the state unchanged. I assume
> -	 * that still data chuncks  can be received by both the peers in
> -	 * SHUDOWN state
> -	 */
> -
> -	{{IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> -	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> -	  * it will send ERROR chunk. So, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 /*
> -	  * SHUTDOWN resent from the client, move to SHUDDOWN_CLI
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 /*
> -	  * SHUTDOWN from the server, move to SHUTDOWN_SER
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 /*
> -	  * client sent SHUDTDOWN_ACK, this should not happen, let's close
> -	  * the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 /*
> -	  * Server sent SHUTDOWN ACK, this is what we are expecting, let's =
move
> -	  * to SHUDOWN_ACK_SER
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 /*
> -	  * SHUTDOWN COM from client, this should not happen, let's close t=
he
> -	  * connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_SHUT_SER
> -	 * SHUTDOWN sent from the server, waitinf for SHUTDOWN ACK from cli=
ent
> -	 */
> -	/*
> -	 * We received the data chuck, keep the state unchanged. I assume
> -	 * that still data chuncks  can be received by both the peers in
> -	 * SHUDOWN state
> -	 */
> -
> -	{{IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> -	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> -	  * it will send ERROR chunk. So, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 /*
> -	  * SHUTDOWN resent from the client, move to SHUDDOWN_CLI
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 /*
> -	  * SHUTDOWN resent from the server, move to SHUTDOWN_SER
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 /*
> -	  * client sent SHUDTDOWN_ACK, this is what we are expecting, let's
> -	  * move to SHUT_ACK_CLI
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 /*
> -	  * Server sent SHUTDOWN ACK, this should not happen, let's close t=
he
> -	  * connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 /*
> -	  * SHUTDOWN COM from client, this should not happen, let's close t=
he
> -	  * connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -
> -	/*
> -	 * State : IP_VS_SCTP_S_SHUT_ACK_CLI
> -	 * SHUTDOWN ACK from the client, awaiting for SHUTDOWN COM from ser=
ver
> -	 */
> -	/*
> -	 * We received the data chuck, keep the state unchanged. I assume
> -	 * that still data chuncks  can be received by both the peers in
> -	 * SHUDOWN state
> -	 */
> -
> -	{{IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> -	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> -	  * it will send ERROR chunk. So, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 /*
> -	  * SHUTDOWN sent from the client, move to SHUDDOWN_CLI
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 /*
> -	  * SHUTDOWN sent from the server, move to SHUTDOWN_SER
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 /*
> -	  * client resent SHUDTDOWN_ACK, let's stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 /*
> -	  * Server sent SHUTDOWN ACK, this should not happen, let's close t=
he
> -	  * connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 /*
> -	  * SHUTDOWN COM from client, this should not happen, let's close t=
he
> -	  * connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 /*
> -	  * SHUTDOWN COMPLETE from server this is what we are expecting.
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -
> -	/*
> -	 * State : IP_VS_SCTP_S_SHUT_ACK_SER
> -	 * SHUTDOWN ACK from the server, awaiting for SHUTDOWN COM from cli=
ent
> -	 */
> -	/*
> -	 * We received the data chuck, keep the state unchanged. I assume
> -	 * that still data chuncks  can be received by both the peers in
> -	 * SHUDOWN state
> -	 */
> +/* SCTP States:
> + * See RFC 2960, 4. SCTP Association State Diagram
> + *
> + * New states (not in diagram):
> + * - INIT1 state: use shorter timeout for dropped INIT packets
> + * - REJECTED state: use shorter timeout if INIT is rejected with AB=
ORT
> + * - INIT, COOKIE_SENT, COOKIE_REPLIED, COOKIE states: for better de=
bugging
> + *
> + * The states are as seen in real server. In the diagram, INIT1, INI=
T,
> + * COOKIE_SENT and COOKIE_REPLIED processing happens in CLOSED state=
=2E
> + *
> + * States as per packets from client (C) and server (S):
> + *
> + * Setup of client connection:
> + * IP_VS_SCTP_S_INIT1: First C:INIT sent, wait for S:INIT-ACK
> + * IP_VS_SCTP_S_INIT: Next C:INIT sent, wait for S:INIT-ACK
> + * IP_VS_SCTP_S_COOKIE_SENT: S:INIT-ACK sent, wait for C:COOKIE-ECHO
> + * IP_VS_SCTP_S_COOKIE_REPLIED: C:COOKIE-ECHO sent, wait for S:COOKI=
E-ACK
> + *
> + * Setup of server connection:
> + * IP_VS_SCTP_S_COOKIE_WAIT: S:INIT sent, wait for C:INIT-ACK
> + * IP_VS_SCTP_S_COOKIE: C:INIT-ACK sent, wait for S:COOKIE-ECHO
> + * IP_VS_SCTP_S_COOKIE_ECHOED: S:COOKIE-ECHO sent, wait for C:COOKIE=
-ACK
> + */
> =20
> -	{{IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 /*
> -	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> -	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> -	  * an INIT ACK using the same parameters it sent in its  original
> -	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> -	  */
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 /*
> -	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> -	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> -	  * than the COOKIE-WAIT state, the endpoint should discard the
> -	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 /*
> -	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> -	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> -	  * it will send ERROR chunk. So, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 /*
> -	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 /*
> -	  * SHUTDOWN sent from the client, move to SHUDDOWN_CLI
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 /*
> -	  * SHUTDOWN sent from the server, move to SHUTDOWN_SER
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 /*
> -	  * client sent SHUDTDOWN_ACK, this should not happen let's close
> -	  * the connection.
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 /*
> -	  * Server resent SHUTDOWN ACK, stay in the same state
> -	  */
> -	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 /*
> -	  * SHUTDOWN COM from client, this what we are expecting, let's clo=
se
> -	  * the connection
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 /*
> -	  * SHUTDOWN COMPLETE from server this should not happen.
> -	  */
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 },
> -	/*
> -	 * State : IP_VS_SCTP_S_CLOSED
> -	 */
> -	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> -	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> -	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> -	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> -	 }
> +#define sNO IP_VS_SCTP_S_NONE
> +#define sI1 IP_VS_SCTP_S_INIT1
> +#define sIN IP_VS_SCTP_S_INIT
> +#define sCS IP_VS_SCTP_S_COOKIE_SENT
> +#define sCR IP_VS_SCTP_S_COOKIE_REPLIED
> +#define sCW IP_VS_SCTP_S_COOKIE_WAIT
> +#define sCO IP_VS_SCTP_S_COOKIE
> +#define sCE IP_VS_SCTP_S_COOKIE_ECHOED
> +#define sES IP_VS_SCTP_S_ESTABLISHED
> +#define sSS IP_VS_SCTP_S_SHUTDOWN_SENT
> +#define sSR IP_VS_SCTP_S_SHUTDOWN_RECEIVED
> +#define sSA IP_VS_SCTP_S_SHUTDOWN_ACK_SENT
> +#define sRJ IP_VS_SCTP_S_REJECTED
> +#define sCL IP_VS_SCTP_S_CLOSED
> +
> +static const __u8 sctp_states
> +	[IP_VS_DIR_LAST][IP_VS_SCTP_EVENT_LAST][IP_VS_SCTP_S_LAST] =3D {
> +	{ /* INPUT */
> +/*        sNO, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL*/
> +/* d   */{sES, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* i   */{sI1, sIN, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sIN, sIN},
> +/* i_a */{sCW, sCW, sCW, sCS, sCR, sCO, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* c_e */{sCR, sIN, sIN, sCR, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* c_a */{sES, sI1, sIN, sCS, sCR, sCW, sCO, sES, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* s   */{sSR, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sSR, sSS, sSR, sSA=
, sRJ, sCL},
> +/* s_a */{sCL, sIN, sIN, sCS, sCR, sCW, sCO, sCE, sES, sCL, sSR, sCL=
, sRJ, sCL},
> +/* s_c */{sCL, sCL, sCL, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sCL=
, sRJ, sCL},
> +/* err */{sCL, sI1, sIN, sCS, sCR, sCW, sCO, sCL, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* ab  */{sCL, sCL, sCL, sCL, sCL, sRJ, sCL, sCL, sCL, sCL, sCL, sCL=
, sCL, sCL},
> +	},
> +	{ /* OUTPUT */
> +/*        sNO, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL*/
> +/* d   */{sES, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* i   */{sCW, sCW, sCW, sCW, sCW, sCW, sCW, sCW, sES, sCW, sCW, sCW=
, sCW, sCW},
> +/* i_a */{sCS, sCS, sCS, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* c_e */{sCE, sCE, sCE, sCE, sCE, sCE, sCE, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* c_a */{sES, sES, sES, sES, sES, sES, sES, sES, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* s   */{sSS, sSS, sSS, sSS, sSS, sSS, sSS, sSS, sSS, sSS, sSR, sSA=
, sRJ, sCL},
> +/* s_a */{sSA, sSA, sSA, sSA, sSA, sCW, sCO, sCE, sES, sSA, sSA, sSA=
, sRJ, sCL},
> +/* s_c */{sCL, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* err */{sCL, sCL, sCL, sCL, sCL, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* ab  */{sCL, sRJ, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL=
, sCL, sCL},
> +	},
> +	{ /* INPUT-ONLY */
> +/*        sNO, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL*/
> +/* d   */{sES, sI1, sIN, sCS, sCR, sES, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* i   */{sI1, sIN, sIN, sIN, sIN, sIN, sCO, sCE, sES, sSS, sSR, sSA=
, sIN, sIN},
> +/* i_a */{sCE, sCE, sCE, sCE, sCE, sCE, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* c_e */{sES, sES, sES, sES, sES, sES, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* c_a */{sES, sI1, sIN, sES, sES, sCW, sES, sES, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* s   */{sSR, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sSR, sSS, sSR, sSA=
, sRJ, sCL},
> +/* s_a */{sCL, sIN, sIN, sCS, sCR, sCW, sCO, sCE, sCL, sCL, sSR, sCL=
, sRJ, sCL},
> +/* s_c */{sCL, sCL, sCL, sCL, sCL, sCW, sCO, sCE, sES, sSS, sCL, sCL=
, sRJ, sCL},
> +/* err */{sCL, sI1, sIN, sCS, sCR, sCW, sCO, sCE, sES, sSS, sSR, sSA=
, sRJ, sCL},
> +/* ab  */{sCL, sCL, sCL, sCL, sCL, sRJ, sCL, sCL, sCL, sCL, sCL, sCL=
, sCL, sCL},
> +	},
>  };
> =20
> -/*
> - *      Timeout table[state]
> - */
> +#define IP_VS_SCTP_MAX_RTO	((60 + 1) * HZ)
> +
> +/* Timeout table[state] */
>  static const int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] =3D {
> -	[IP_VS_SCTP_S_NONE]         =3D     2 * HZ,
> -	[IP_VS_SCTP_S_INIT_CLI]     =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_INIT_SER]     =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_INIT_ACK_CLI] =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_INIT_ACK_SER] =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_ECHO_CLI]     =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_ECHO_SER]     =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_ESTABLISHED]  =3D    15 * 60 * HZ,
> -	[IP_VS_SCTP_S_SHUT_CLI]     =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_SHUT_SER]     =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_SHUT_ACK_CLI] =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_SHUT_ACK_SER] =3D     1 * 60 * HZ,
> -	[IP_VS_SCTP_S_CLOSED]       =3D    10 * HZ,
> -	[IP_VS_SCTP_S_LAST]         =3D     2 * HZ,
> +	[IP_VS_SCTP_S_NONE]			=3D 2 * HZ,
> +	[IP_VS_SCTP_S_INIT1]			=3D (0 + 3 + 1) * HZ,
> +	[IP_VS_SCTP_S_INIT]			=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_COOKIE_SENT]		=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_COOKIE_REPLIED]		=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_COOKIE_WAIT]		=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_COOKIE]			=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_COOKIE_ECHOED]		=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_ESTABLISHED]		=3D 15 * 60 * HZ,
> +	[IP_VS_SCTP_S_SHUTDOWN_SENT]		=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_SHUTDOWN_RECEIVED]	=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_SHUTDOWN_ACK_SENT]	=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_REJECTED]			=3D (0 + 3 + 1) * HZ,
> +	[IP_VS_SCTP_S_CLOSED]			=3D IP_VS_SCTP_MAX_RTO,
> +	[IP_VS_SCTP_S_LAST]			=3D 2 * HZ,
>  };
> =20
>  static const char *sctp_state_name_table[IP_VS_SCTP_S_LAST + 1] =3D =
{
> -	[IP_VS_SCTP_S_NONE]         =3D    "NONE",
> -	[IP_VS_SCTP_S_INIT_CLI]     =3D    "INIT_CLI",
> -	[IP_VS_SCTP_S_INIT_SER]     =3D    "INIT_SER",
> -	[IP_VS_SCTP_S_INIT_ACK_CLI] =3D    "INIT_ACK_CLI",
> -	[IP_VS_SCTP_S_INIT_ACK_SER] =3D    "INIT_ACK_SER",
> -	[IP_VS_SCTP_S_ECHO_CLI]     =3D    "COOKIE_ECHO_CLI",
> -	[IP_VS_SCTP_S_ECHO_SER]     =3D    "COOKIE_ECHO_SER",
> -	[IP_VS_SCTP_S_ESTABLISHED]  =3D    "ESTABISHED",
> -	[IP_VS_SCTP_S_SHUT_CLI]     =3D    "SHUTDOWN_CLI",
> -	[IP_VS_SCTP_S_SHUT_SER]     =3D    "SHUTDOWN_SER",
> -	[IP_VS_SCTP_S_SHUT_ACK_CLI] =3D    "SHUTDOWN_ACK_CLI",
> -	[IP_VS_SCTP_S_SHUT_ACK_SER] =3D    "SHUTDOWN_ACK_SER",
> -	[IP_VS_SCTP_S_CLOSED]       =3D    "CLOSED",
> -	[IP_VS_SCTP_S_LAST]         =3D    "BUG!"
> +	[IP_VS_SCTP_S_NONE]			=3D "NONE",
> +	[IP_VS_SCTP_S_INIT1]			=3D "INIT1",
> +	[IP_VS_SCTP_S_INIT]			=3D "INIT",
> +	[IP_VS_SCTP_S_COOKIE_SENT]		=3D "C-SENT",
> +	[IP_VS_SCTP_S_COOKIE_REPLIED]		=3D "C-REPLIED",
> +	[IP_VS_SCTP_S_COOKIE_WAIT]		=3D "C-WAIT",
> +	[IP_VS_SCTP_S_COOKIE]			=3D "COOKIE",
> +	[IP_VS_SCTP_S_COOKIE_ECHOED]		=3D "C-ECHOED",
> +	[IP_VS_SCTP_S_ESTABLISHED]		=3D "ESTABLISHED",
> +	[IP_VS_SCTP_S_SHUTDOWN_SENT]		=3D "S-SENT",
> +	[IP_VS_SCTP_S_SHUTDOWN_RECEIVED]	=3D "S-RECEIVED",
> +	[IP_VS_SCTP_S_SHUTDOWN_ACK_SENT]	=3D "S-ACK-SENT",
> +	[IP_VS_SCTP_S_REJECTED]			=3D "REJECTED",
> +	[IP_VS_SCTP_S_CLOSED]			=3D "CLOSED",
> +	[IP_VS_SCTP_S_LAST]			=3D "BUG!",
>  };
> =20
> =20
> @@ -945,17 +394,20 @@ set_sctp_state(struct ip_vs_proto_data *pd, str=
uct ip_vs_conn *cp,
>  		}
>  	}
> =20
> -	event =3D sctp_events[chunk_type];
> +	event =3D (chunk_type < sizeof(sctp_events)) ?
> +		sctp_events[chunk_type] : IP_VS_SCTP_DATA;
> =20
> -	/*
> -	 *  If the direction is IP_VS_DIR_OUTPUT, this event is from server
> -	 */
> -	if (direction =3D=3D IP_VS_DIR_OUTPUT)
> -		event++;
> -	/*
> -	 * get next state
> +	/* Update direction to INPUT_ONLY if necessary
> +	 * or delete NO_OUTPUT flag if output packet detected
>  	 */
> -	next_state =3D sctp_states_table[cp->state][event].next_state;
> +	if (cp->flags & IP_VS_CONN_F_NOOUTPUT) {
> +		if (direction =3D=3D IP_VS_DIR_OUTPUT)
> +			cp->flags &=3D ~IP_VS_CONN_F_NOOUTPUT;
> +		else
> +			direction =3D IP_VS_DIR_INPUT_ONLY;
> +	}
> +
> +	next_state =3D sctp_states[direction][event][cp->state];
> =20
>  	if (next_state !=3D cp->state) {
>  		struct ip_vs_dest *dest =3D cp->dest;
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_=
vs_sync.c
> index f6046d9..2fc6639 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -461,9 +461,10 @@ static int ip_vs_sync_conn_needed(struct netns_i=
pvs *ipvs,
>  	} else if (unlikely(cp->protocol =3D=3D IPPROTO_SCTP)) {
>  		if (!((1 << cp->state) &
>  		      ((1 << IP_VS_SCTP_S_ESTABLISHED) |
> -		       (1 << IP_VS_SCTP_S_CLOSED) |
> -		       (1 << IP_VS_SCTP_S_SHUT_ACK_CLI) |
> -		       (1 << IP_VS_SCTP_S_SHUT_ACK_SER))))
> +		       (1 << IP_VS_SCTP_S_SHUTDOWN_SENT) |
> +		       (1 << IP_VS_SCTP_S_SHUTDOWN_RECEIVED) |
> +		       (1 << IP_VS_SCTP_S_SHUTDOWN_ACK_SENT) |
> +		       (1 << IP_VS_SCTP_S_CLOSED))))
>  			return 0;
>  		force =3D cp->state !=3D cp->old_state;
>  		if (force && cp->state !=3D IP_VS_SCTP_S_ESTABLISHED)
> --=20
> 1.7.3.4
>=20
