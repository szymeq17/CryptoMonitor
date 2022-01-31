open Core
open Coin

let get_current_time () = 
    Time.format 
        (Time.now ()) 
        "%Y-%m-%d %H:%M:%S"
         ~zone:(Time.Zone.of_utc_offset ~hours:1)

let price_drop sym target_price curr_price currency = 
    Printf.printf 
        "\n\x1b[1;37m[%s]\x1b[1;34m %s\x1b[0m price is under \x1b[1;33m%f\x1b[0m\x1b[0;34m %s\x1b[0m now! Current price: \x1b[1;37m%f\x1b[0;34m %s\x1b[0m\n" 
        (get_current_time ())
        sym
        target_price
        currency
        curr_price
        currency

let price_drop_with_profit sym target_price curr_price profit currency = 
    Printf.printf 
        "\n\x1b[1;37m[%s]\x1b[1;34m %s\x1b[0m price is under \x1b[1;33m%f\x1b[0m\x1b[0;34m %s\x1b[0m now! Current price: \x1b[1;37m%f\x1b[0;34m %s\x1b[0m, Profit: \x1b[1;37m%f\x1b[0;34m %s\x1b[0m\n" 
        (get_current_time ())
        sym
        target_price
        currency
        curr_price
        currency
        profit
        currency
let coin_price_not_found sym = 
    Printf.printf 
        "\n\x1b[0;31m[ERROR]\x1b[0m Could not find price of coin with given symbol: \x1b[1;31m%s\x1b[0m!\n" 
        sym
let coin_info coin =
    match coin with
        | Inapplicable -> ()
        | Coin(symbol, target_price, currency, pocket,
               target_profit, _, notification_triggerer) ->
            let notification_triggerer = 
                    match notification_triggerer with
                    | Price          -> "Price"
                    | PriceAndProfit -> "Price and profit"
                    | Profit         -> "Profit"
            in
                Printf.printf
                "[\x1b[34mSymbol:\x1b[0m %s, \x1b[34mTarget price:\x1b[0m %s, \x1b[34mCurrency:\x1b[0m %s, \x1b[34mPocket:\x1b[0m %s, \x1b[34mTarget profit\x1b[0m %s, \x1b[34mNotification triggerer:\x1b[0m %s]\n"
                symbol (Float.to_string target_price) currency (Float.to_string pocket) (Float.to_string target_profit) notification_triggerer


let interval_info interval =
    Printf.printf "\n\x1b[1;37m%s\x1b[1;34m%ds\x1b[0m\n\n" "Interval: " interval
let coins_info coins =
    Printf.printf "\n\x1b[1;37m%s\x1b[0m\n\n" "Tracked coins:";
    List.iter ~f:(fun coin -> coin_info coin) coins
     
let start_tracking () =
    Printf.printf "\n\x1b[1;37m%s\x1b[0m\n\n" "Tracking started!"
let crypto_monitor_start = 
    try (
        let name = In_channel.read_all "./lib/notifier/start.txt" in
        Printf.printf "\x1b[1;34m%s\x1b[0m" name) with
    _ -> Printf.printf "\x1b[0;33m[WARN]\x1b[0m %s\n" "File: /lib/notisfier/start.txt is missing!"
        
let config_loaded () = 
    Printf.printf "\n\x1b[1;32m%s\x1b[0m\n\n" "Config file has been loaded successfully!"

let config_not_found () = 
    Printf.printf "\n\x1b[1;31m%s\x1b[0m\n\n" "Config file \"config.json\" not found! Aborting..."