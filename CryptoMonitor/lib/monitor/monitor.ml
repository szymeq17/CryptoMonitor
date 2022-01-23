open Lwt
open Cohttp_lwt_unix
open Core
open Notifier
open Config

let body symbol currency =
  Client.get (Uri.of_string ("https://min-api.cryptocompare.com/data/price?fsym=" ^ symbol ^ "&tsyms=" ^ currency))
  >>= fun (_, body) ->
  body |> Cohttp_lwt.Body.to_string 
  >|= fun body -> body
  
let check_prices () = 
  let json = get_config_json "config.json" in
  List.iter (get_coin_list json) ~f:(fun coin ->
    match coin with
    | Coin(symbol, target_price, currency) ->
  let body = Lwt_main.run (body symbol currency) in
  let json = Yojson.Basic.from_string body in
  let open Yojson.Basic.Util in
  try (
    let price = json |> member currency |> to_float in
    if (Float.compare price target_price) <= 0 then 
        price_drop symbol price currency
        else ()) with
    _ -> coin_not_found symbol)