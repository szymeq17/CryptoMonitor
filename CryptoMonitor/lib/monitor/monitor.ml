open Lwt
open Cohttp_lwt_unix
open Core
open Notifier
open Config
open Coin

let body symbol currency =
  Client.get (Uri.of_string ("https://min-api.cryptocompare.com/data/price?fsym=" ^ symbol ^ "&tsyms=" ^ currency))
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
            | Profit -> price_and_profit_action symbol current_price target_price pocket target_profit currency
            | PriceAndProfit -> price_and_profit_action symbol current_price target_price pocket target_profit currency
  
let check_prices json_coins = 
  List.iter (List.map json_coins ~f:json_to_coin) ~f:(fun coin ->
    match coin with
    | Inapplicable -> ()
    | Coin(symbol, _, currency, _, _, _, _) ->
  let body = Lwt_main.run (body symbol currency) in
  let json = Yojson.Basic.from_string body in
  let open Yojson.Basic.Util in
  try (
    let price = json |> member currency |> to_float in
    perform_action coin price) with
    _ -> coin_price_not_found symbol)

let rec run_monitor coins interval =
  check_prices coins;
  print_endline "";
  Unix.sleep interval;
  run_monitor coins interval

let run () =
  let config = get_config_json "config.json" in
  let json_coins = get_coin_list config in
  let interval = 
    match get_interval config with
      | Some v -> v
      | None   -> 30
  in
  run_monitor json_coins interval
  


