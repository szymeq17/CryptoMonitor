open Core

let get_current_time () = 
    Time.format 
        (Time.now ()) 
        "%Y-%m-%d %H:%M:%S"
         ~zone:(Time.Zone.of_utc_offset ~hours:1)

let price_drop sym target_price curr_price currency = 
    Printf.printf 
        "\n\x1b[32m[%s]\x1b[1;31m %s\x1b[0m price is under \x1b[1;33m%f\x1b[0;33m now! 
        Current price: \x1b[1;33m%f\x1b[0;33m %s\x1b[33m\n" 
        (get_current_time ())
        sym
        target_price
        curr_price
        currency

let price_drop_with_profit sym target_price curr_price profit currency = 
    Printf.printf 
        "\n\x1b[32m[%s]\x1b[1;31m %s\x1b[0m price is under \x1b[1;33m%f\x1b[0;33m now! 
        Current price: \x1b[1;33m%f\x1b[0;33m %s\x1b[33m, Profit: \x1b[1;33m%f\x1b[0;33m %s\x1b[33m\n" 
        (get_current_time ())
        sym
        target_price
        curr_price
        currency
        profit
        currency
let coin_price_not_found sym = 
    Printf.printf 
        "\n\x1b[0;31m[ERROR]\x1b[0m Could not find price of coin with given symbol: \x1b[1;31m%s\x1b[0m!\n" 
        sym