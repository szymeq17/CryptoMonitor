open Lwt
open Cohttp_lwt_unix
open Core
open Notifier
open Config
open Coin

module Symbols = Set.Make(String)
module Currencies = Set.Make(String)

let body symbols currencies =
  Client.get (Uri.of_string ("https://min-api.cryptocompare.com/data/pricemulti?fsyms=" ^ symbols ^ "&tsyms=" ^ currencies))
  >>= fun (_, body) ->
  body |> Cohttp_lwt.Body.to_string 
  >|= fun body -> body

let price_action symbol current_price target_price currency = 
  if (Float.compare current_price target_price) <= 0 then
    price_drop symbol target_price current_price currency
  else ()

let price_and_profit_action symbol current_price target_price pocket target_profit currency =
  let profit = pocket *. current_price in
  if Float.compare profit target_profit >= 0 then
    price_drop_with_profit symbol target_price current_price profit currency
  else ()

let perform_action coin current_price =
  match coin with
    | Inapplicable -> ()
    | Coin(symbol, target_price, currency, pocket,
            target_profit, _, notification_triggerer) ->
        match notification_triggerer with
            | Price -> price_action symbol current_price target_price currency
            | Profit -> 
              price_and_profit_action symbol current_price target_price pocket target_profit currency
            | PriceAndProfit -> 
              price_and_profit_action symbol current_price target_price pocket target_profit currency
  
let check_prices coins symbols currencies = 
  let body = Lwt_main.run (body symbols currencies) in
  let json = Yojson.Basic.from_string body in
  let open Yojson.Basic.Util in
  List.iter coins ~f:(fun coin ->
    match coin with
     | Inapplicable -> ()
     | Coin(symbol, _, currency, _, _, _, _) ->
    try (
      let price = json |> member symbol |> member currency |> to_float in
      perform_action coin price) with
      _ -> 
        try (
          let price = json |> member symbol |> member currency 
          |> to_int |> Int.to_float in
          perform_action coin price) with 
        _ -> coin_price_not_found symbol)

let set_to_string set =
  Set.fold ~f:(fun elem init -> init ^ "," ^ elem) set ~init:""

let get_symbols coins = 
  let rec find_symbols coins symbols =
    match coins with
      | [] -> symbols
      | Inapplicable :: coins -> find_symbols coins symbols
      | Coin(symbol, _, _, _, _, _, _) :: coins -> 
        find_symbols coins (Symbols.add symbols symbol)
  in
  find_symbols coins Symbols.empty

let get_currencies coins = 
  let rec find_currencies coins currencies =
    match coins with
      | [] -> currencies
      | Inapplicable :: coins -> find_currencies coins currencies
      | Coin(_, _, currency, _, _, _, _) :: coins -> 
        find_currencies coins (Currencies.add currencies currency)
  in
  find_currencies coins Currencies.empty
let rec run_monitor coins symbols currencies interval =
  check_prices coins symbols currencies;
  print_endline "";
  Unix.sleep interval;
  run_monitor coins symbols currencies interval

let run () =
  let config = get_config_json "config.json" in
  let json_coins = get_coin_list config in
  let coins = List.map json_coins ~f:json_to_coin in
  let symbols = set_to_string (get_symbols coins) in
  let currencies = set_to_string (get_currencies coins) in
  let interval = 
    match get_interval config with
      | Some v -> v
      | None   -> 30
  in
  crypto_monitor_start;
  coins_info coins;
  interval_info interval;
  run_monitor coins symbols currencies interval