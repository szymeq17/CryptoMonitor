val get_config_json : string -> Yojson.Basic.t
val json_to_coin : Yojson.Basic.t -> Coin.coin
val get_coin_list : Yojson.Basic.t -> Yojson.Basic.t list
val get_interval : Yojson.Basic.t -> int option
