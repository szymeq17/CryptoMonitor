open Lwt
open Cohttp_lwt_unix
open Core
open Notifier
open Config

let body symbol =
  Client.get (Uri.of_string ("https://min-api.cryptocompare.com/data/price?fsym=" ^ symbol ^ "&tsyms=USD")) >>= fun (_, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  body

let () =
  let json = get_config_json "config.json" in
  List.iter (get_coin_list json) ~f:(fun coin ->
    match coin with
    | Coin(symbol, _, _) ->
  let body = Lwt_main.run (body symbol) in
  let json = Yojson.Basic.from_string body in
  let open Yojson.Basic.Util in
  try (let price = json |> member "USD" |> to_float in
        price_drop symbol price "USD") with
    _ -> coin_not_found symbol)