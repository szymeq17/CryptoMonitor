open Coin

val price_drop : string -> float -> float -> string -> unit
val price_drop_with_profit :
  string -> float -> float -> float -> string -> unit
val coin_price_not_found : string -> unit
val crypto_monitor_start : unit
val coins_info : coin list -> unit
val interval_info : int -> unit