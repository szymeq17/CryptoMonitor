open Core

let get_current_time () = 
    Time.format 
        (Time.now ()) 
        "%Y-%m-%d %H:%M:%S"
         ~zone:(Time.Zone.of_utc_offset ~hours:1)

let price_drop sym curr_price currency = 
    Printf.printf 
        "\n\x1b[32m[%s]\x1b[1;31m %s\x1b[0m price dropped! Current price: \x1b[1;33m%f\x1b[0;33m %s\x1b[33m\n" 
        (get_current_time ())
        sym
        curr_price
        currency

let coin_not_found sym = 
    Printf.printf 
        "\n\x1b[0;31m[ERROR]\x1b[0m Could not find coin with given symbol: \x1b[1;31m%s\x1b[0m - removed from tracking list\n" 
        sym